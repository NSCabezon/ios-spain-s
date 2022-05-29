import Foundation

public struct EcommerceOperationDataDTO: Codable {
    public let cardNumber: String
    public let commerce: String
    public let amount: Double
    public let currency: String
    public let cardName: String
    public let state: String

    private enum CodingKeys: String, CodingKey {
        case cardNumber = "numTarjeta"
        case commerce = "comercio"
        case amount = "importe"
        case currency = "moneda"
        case cardName = "nombreTarjeta"
        case state = "estado"
    }
}
