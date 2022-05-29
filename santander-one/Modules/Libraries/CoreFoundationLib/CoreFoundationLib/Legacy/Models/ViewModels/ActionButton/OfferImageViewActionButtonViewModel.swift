import UIKit.UIImage

public struct OfferImageViewActionButtonViewModel: Equatable {
    public enum ImageDescriptor: Equatable {
        case image(UIImage?)
        case imageURL(String)
        public static func == (lhs: ImageDescriptor, rhs: ImageDescriptor) -> Bool {
            switch (lhs, rhs) {
            case (.image(let lhsImage), .image(let rhsImage)):
                return lhsImage == rhsImage
            case (.imageURL(let lhsUrl), .imageURL(let rhsUrl)):
                return lhsUrl == rhsUrl
            default:
                return true
            }
        }
        
    }
    public let image: ImageDescriptor?
    public var identifier: String?
    
    public init() {
        self.image = nil
    }
    
    public init(image: UIImage?, identifier: String? = nil) {
        self.image = .image(image)
        self.identifier = identifier
    }
    
    public init(url: String, identifier: String? = nil) {
        self.image = .imageURL(url)
        self.identifier = identifier
    }
}
