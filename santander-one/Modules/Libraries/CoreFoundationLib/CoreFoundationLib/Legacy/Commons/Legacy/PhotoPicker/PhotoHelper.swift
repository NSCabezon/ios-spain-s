import UIKit
import OpenCombine

public enum PhotoType {
    case camera
    case photoLibrary
}

public enum PhotoHelperError: Error {
    case noPermissionCamera
    case noPermissionPhotoLibrary
}

public enum PhotoCompressionStrategy {
    case normalCompression
    case compressionAndResize(maxBytes: Int, imageSize: CGSize)
}

public protocol PhotoHelperDelegate: AnyObject {
    var viewForPresentation: UIViewController? { get }
    func selectedImage(image: Data)
    func showError(error: PhotoHelperError)
}

public class PhotoHelperReactive: NSObject {
    private let photoDataSubject = PassthroughSubject<Data, PhotoHelperError>()
    public let photoDataPublisher: AnyPublisher<Data, PhotoHelperError>
    public var compressionQuality: CGFloat = 1.0
    public var strategy: PhotoCompressionStrategy = .normalCompression
    private let photoPermissionHelper = PhotoPermissionHelper()
    private weak var associatedViewController: UIViewController?
    
    public init(associatedViewController: UIViewController?) {
        self.associatedViewController = associatedViewController
        self.photoDataPublisher = photoDataSubject.eraseToAnyPublisher()
    }
    
    public func askImage(type: PhotoType) {
        let permissionType: PhotoPermissionType
        switch type {
        case .camera:
            permissionType = .cameraAccess
        case .photoLibrary:
            permissionType = .photoLibraryAccess
        }
        switch photoPermissionHelper.authorizationStatus(type: permissionType) {
        case .authorized:
            showEditor(type: type)
        case .denied, .restricted:
            notAuthorized(type: type)
        case .notDetermined:
            photoPermissionHelper.askAuthorization(type: permissionType, completion: { [weak self] (authorized: Bool) in
                guard let helper = self else { return }
                if authorized {
                    DispatchQueue.main.async {
                        helper.showEditor(type: type)
                    }
                }
            })
        }
    }
    
    private func showEditor(type: PhotoType) {
        let picker = UIImagePickerController()
        switch type {
        case .camera:
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
        case .photoLibrary:
            picker.sourceType = .photoLibrary
        }
        picker.allowsEditing = true
        picker.delegate = self
        associatedViewController?.present(picker, animated: true, completion: nil)
    }
    
    private func notAuthorized(type: PhotoType) {
        switch type {
        case .camera:
            photoDataSubject.send(completion: .failure(PhotoHelperError.noPermissionCamera))
        case .photoLibrary:
            photoDataSubject.send(completion: .failure(PhotoHelperError.noPermissionPhotoLibrary))
        }
    }
}

public class PhotoHelper: NSObject {
    public var compressionQuality: CGFloat = 1.0
    public var strategy: PhotoCompressionStrategy = .normalCompression
    private let photoPermissionHelper = PhotoPermissionHelper()
    private weak var delegate: PhotoHelperDelegate?
    
    public init(delegate: PhotoHelperDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    public func askImage(type: PhotoType) {
        let permissionType: PhotoPermissionType
        switch type {
        case .camera:
            permissionType = .cameraAccess
        case .photoLibrary:
            permissionType = .photoLibraryAccess
        }
        switch photoPermissionHelper.authorizationStatus(type: permissionType) {
        case .authorized:
            showEditor(type: type)
        case .denied, .restricted:
            notAuthorized(type: type)
        case .notDetermined:
            photoPermissionHelper.askAuthorization(type: permissionType, completion: { [weak self] (authorized: Bool) in
                guard let helper = self else { return }
                if authorized {
                    DispatchQueue.main.async {
                        helper.showEditor(type: type)
                    }
                }
            })
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension PhotoHelperReactive: UINavigationControllerDelegate {}
extension PhotoHelper: UINavigationControllerDelegate {}

// MARK: - UIImagePickerControllerDelegate

extension PhotoHelperReactive: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else {
            image = info[.originalImage] as? UIImage
        }
        self.applyCompressionStrategy(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PhotoHelper: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else {
            image = info[.originalImage] as? UIImage
        }
        self.applyCompressionStrategy(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
}

private extension PhotoHelperReactive {
    func applyCompressionStrategy(image: UIImage?) {
        guard let image = image else { return  }
        switch strategy {
        case .normalCompression:
            if let data = image.jpegData(compressionQuality: compressionQuality) {
                photoDataSubject.send(data)
            }
        case .compressionAndResize(let maxBytes, let imageSize):
            var needCompression = true
            var percentageImage: CGFloat = 100.0
            let qualities = [0.75, 0.5, 0.25, 0]
            while needCompression {
                let newSize = CGSize(width: imageSize.width * percentageImage / 100, height: imageSize.height * percentageImage / 100)
                let resizeImage = image.resize(to: newSize)
                var data = resizeImage.jpegData(compressionQuality: 1) ?? Data()
                var newImageSize = data.count
                qualities.forEach { compression in
                    guard newImageSize >= maxBytes else { return }
                    data = resizeImage.jpegData(compressionQuality: CGFloat(compression)) ?? Data()
                    newImageSize = data.count
                }
                if newImageSize > maxBytes {
                    needCompression = true
                    percentageImage -= 10
                } else {
                    needCompression = false
                    photoDataSubject.send(data)
                }
            }
        }
    }
}

private extension PhotoHelper {
    func applyCompressionStrategy(image: UIImage?) {
        guard let image = image else { return  }
        switch strategy {
        case .normalCompression:
            if let data = image.jpegData(compressionQuality: compressionQuality) {
                delegate?.selectedImage(image: data)
            }
        case .compressionAndResize(let maxBytes, let imageSize):
            var needCompression = true
            var percentageImage: CGFloat = 100.0
            while needCompression {
                let newSize = CGSize(width: imageSize.width * percentageImage / 100, height: imageSize.height * percentageImage / 100)
                let resizeImage = image.resize(to: newSize)
                var data = resizeImage.jpegData(compressionQuality: 1) ?? Data()
                var newImageSize = data.count
                let qualities = [0.75, 0.5, 0.25, 0]
                qualities.forEach { compression in
                    guard newImageSize >= maxBytes else { return }
                    data = resizeImage.jpegData(compressionQuality: CGFloat(compression)) ?? Data()
                    newImageSize = data.count
                }
                if newImageSize > maxBytes {
                    needCompression = true
                    percentageImage -= 10
                } else {
                    needCompression = false
                    delegate?.selectedImage(image: data)
                }
            }
        }
    }
    
    func notAuthorized(type: PhotoType) {
        switch type {
        case .camera:
            delegate?.showError(error: .noPermissionCamera)
        case .photoLibrary:
            delegate?.showError(error: .noPermissionPhotoLibrary)
        }
    }
    
    func showEditor(type: PhotoType) {
        let picker = UIImagePickerController()
        switch type {
        case .camera:
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
        case .photoLibrary:
            picker.sourceType = .photoLibrary
        }
        picker.allowsEditing = true
        picker.delegate = self
        delegate?.viewForPresentation?.present(picker, animated: true, completion: nil)
    }
}

private extension UIImage {
    func resize(to newSize: CGSize) -> UIImage {
        let widthRatio  = newSize.width / size.width
        let heightRatio = newSize.height / size.height
        let newSize = widthRatio > heightRatio ?
            CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
            CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
