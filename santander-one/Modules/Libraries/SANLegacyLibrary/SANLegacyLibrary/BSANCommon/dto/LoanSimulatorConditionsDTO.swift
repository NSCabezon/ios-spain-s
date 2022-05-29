import SwiftyJSON

public struct LoanSimulatorConditionsDTO: Codable, RestParser {
    public let installmentWithBonus: Double?
    public let loanTotalAmount: Int?
    public let insurancetotalPrime: Int?
    public let taeWithBonus: Double?
    public let interestType: Double?
    public let openingCommission: Double?
    public let feeControl: String?
    public let paymentIndicator: String?

    public init(json: JSON) {
        self.installmentWithBonus = json["installmentWithBonus"].double
        self.loanTotalAmount = json["loanTotalAmount"].int
        self.insurancetotalPrime = json["insurancetotalPrime"].int
        self.taeWithBonus = json["taeWithBonus"].double
        self.interestType = json["interestType"].double
        self.openingCommission = json["openingCommission"].double
        self.feeControl = json["feeControl"].string
        self.paymentIndicator = json["paymentIndicator"].string
    }
}
