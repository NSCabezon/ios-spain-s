import Foundation

public struct TransferScheduledDetailDTO: Codable {
    public var beneficiary: String?
    public var transferAmount: AmountDTO?
    public var concept: String?
    public var currency: String?
    public var dateNextExecution: Date?
    public var dateStartValidity: Date?
    public var dateEndValidity: Date?
    public var IndicatorResidence: String?
    public var actuanteCode: String?
    public var actuanteNumber: String?
    public var actuanteCompany: String?
    public var iban: IBANDTO?
    public var ibanBeneficiary: IBANDTO?
    public var periodicalType: String?
    public var scheduledDayTransfer: String?
    public var countryDestination: String?

    public init() {}
}
