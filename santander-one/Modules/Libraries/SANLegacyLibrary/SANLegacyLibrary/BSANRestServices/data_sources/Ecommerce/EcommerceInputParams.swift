import Foundation

public struct EcommerceConfirmWithFingerPrintInputParams: Codable {
    let shortUrl: String
    let token: String
    let footprint: String
    var ip: String = "0.0.0.0"

    public init(shortUrl: String, token: String, footprint: String) {
        self.shortUrl = shortUrl
        self.token = token
        self.footprint = footprint
    }
}
