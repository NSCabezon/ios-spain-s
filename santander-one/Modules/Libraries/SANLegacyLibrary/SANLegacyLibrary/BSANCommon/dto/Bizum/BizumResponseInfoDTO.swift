//import Foundation

public struct BizumResponseInfoDTO: Codable {
    public let info: BizumTransferInfoDTO
    public let operationId: String
    
    private enum CodingKeys: String, CodingKey {
        case info = "info"
        case operationId = "idOperacion"
    }
}
