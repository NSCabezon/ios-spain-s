import CoreDomain

public struct BannerDTO {
    public let app: String
    public let height: CGFloat
    public let width: Float
    public let url: String
    
    public init(app: String, height: Float, width: Float, url: String) {
        self.app = app
        self.height = CGFloat(height)
        self.width = width
        self.url = url
    }
}

extension BannerDTO: BannerRepresentable {}
