import Foundation
import CoreFoundationLib

extension BizumAmountPresenter {
    func cameraWasTapped() {
        self.view?.showOptionsToAddImage(onCamera: {
             self.photoHelper?.askImage(type: .camera)
        }, onGallery: {
            self.photoHelper?.askImage(type: .photoLibrary)
        })
    }
}

extension BizumAmountPresenter: PhotoHelperDelegate {
    var viewForPresentation: UIViewController? { return view as? UIViewController }
    func selectedImage(image: Data) {
        self.multimediaViewModel?.showThumbnailImage(image)
    }
    
    func showError(error: PhotoHelperError) {
        let keyDesc: String
        switch error {
        case .noPermissionCamera:
            keyDesc = "permissionsAlert_text_camera"
        case .noPermissionPhotoLibrary:
            keyDesc = "permissionsAlert_text_photos"
        }
        self.view?.showRequestGalleryAccess(keyDesc)
    }
}
