import Foundation

public struct BizumOperationMultipleDetailDTO: Codable {
    public let opeartionId: String?
    public let receptorId: String?
    public let receptorAlias: String?
    public let state: String?
    
    private enum CodingKeys: String, CodingKey {
        case opeartionId = "idOperacion"
        case receptorId = "idUsuarioReceptor"
        case receptorAlias = "aliasReceptor"
        case state = "estado"
    }
}
