import Foundation

public struct BizumIbanDTO: Codable {
    public let country: String?
    public let checkDigits: String?
    public let codbban: String?

    private enum CodingKeys: String, CodingKey {
        case country = "pais"
        case checkDigits = "digitodecontrol"
        case codbban
    }
}
