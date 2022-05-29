import UIKit

private struct PickImage {
    let imageBase64: String
}

extension PickImage: Encodable {
    private enum CodingKeys: String, CodingKey {
        case image
        case imageBase64
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var imageContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .image)
        try imageContainer.encode(imageBase64, forKey: .imageBase64)
    }
}

class PickerImageProcessing {
    
    enum Constants {
        static let higherImageLimit: CGFloat = 1280.0
        static let lowerImageLimit: CGFloat = 720.0
    }
    
    let imageData: Data
    var serializedImage: String?
    
    private var resized: UIImage?
    private var encoded: Data?
    
    init(imageData: Data) {
        self.imageData = imageData
    }
    
    func processImage(completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.resize().encodeData().serialize()
            DispatchQueue.main.async {
                completion(self.serializedImage)
            }
        }
    }
    
    @discardableResult
    private func resize() -> Self {
        guard let image = UIImage(data: imageData) else {
            return self
        }
        resized = resize(image: image)
        
        return self
    }
    
    @discardableResult
    private func encodeData() -> Self {
        guard let resized = resized else {
            return self
        }
        encoded = encodeData(image: resized, withQuality: 0.7)
        
        return self
    }
    
    @discardableResult
    private func serialize() -> Self {
        guard let encoded = encoded else {
            return self
        }
        let encodedString = encoded.base64EncodedString()
        
        serializedImage = serialize(image: PickImage(imageBase64: encodedString))
        
        return self
    }
    
    private func resize(image: UIImage) -> UIImage? {
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        
        var result: UIImage? = image
        if height >= width && (height > Constants.higherImageLimit || height > Constants.lowerImageLimit) {
            let scale = min(Constants.higherImageLimit / height, Constants.lowerImageLimit / width)
            result = image.resize(to: CGSize(width: width * scale, height: height * scale))
        } else if width > height && (width > Constants.higherImageLimit || height > Constants.lowerImageLimit) {
            let scale = min(Constants.higherImageLimit / width, Constants.lowerImageLimit / height)
            result = image.resize(to: CGSize(width: width * scale, height: height * scale))
        }
        return result
    }
    
    private func encodeData(image: UIImage, withQuality quality: CGFloat) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
    
    private func serialize(image: PickImage) -> String? {
        guard let data = try? JSONEncoder().encode(image) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
