import Foundation

public struct MifidTestIndicatorDTO: Codable {
    public var testId: String?
    public var mifidQuestionnaireIndicatorModel: MifidQuestionnaireIndicatorDTO?
    public var contract: ContractDTO?
    public var testStatus: MifidTestStatusDTO?
    public var indVigencia: Bool?
    public var startDate: Date?
    public var endDate: Date?
    public var gdId: String?
    public var tipoDocumental: String?
    public var tipoDocumentalDigi: String?

    public init() {}
}
