import Foundation

public struct PensionContributionsDTO: Codable {
    public var statusPlan: String?
    public var highDate: Date?
    public var typePension: String?
    public var description: String?
    public var lastUploaded: Date?
    public var nextReceiptDate: Date?
    public var contributionAmount: AmountDTO?
    public var numberQuotaPeriodic: Int?
    public var literalPeriod: String?
    public var revaluationAnnulment: String?
    public var timeStampTable: Date?

    public init() {}
}
