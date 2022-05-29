import Foundation

public struct BizumOperationMultiDTO: Codable {
    public let opeartionId: String?
    public let concept: String?
    public let amount: Double?
    public let emitterId: String?
    public let emitterAlias: String?
    public let emitterIban: BizumIbanDTO?
    public let type: String?
    
    private enum CodingKeys: String, CodingKey {
        case opeartionId = "idOperacionMultiple"
        case concept = "concepto"
        case amount = "importe"
        case emitterId = "idUsuarioEmisor"
        case emitterAlias = "aliasEmisor"
        case emitterIban = "ibanEmisor"
        case type = "tipo"
    }
}
