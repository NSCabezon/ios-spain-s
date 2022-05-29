import Foundation

public struct BizumOperationMultiListDTO: Codable {
    public let info: BizumOperationMultiListInfoDTO
    public let elementsTotal: Int?
    public let pagesTotal: Int?
    public let moreData: String?
    public var operations: [BizumOperationMultiDTO] {
        return operationList?.operations ?? []
    }
    private let operationList: BizumOperationMultiListContentDTO?

    private enum CodingKeys: String, CodingKey {
        case info
        case elementsTotal = "numeroTotalElementos"
        case pagesTotal = "numeroTotalpaginas"
        case moreData = "masDatos"
        case operationList = "listaOperacionsMultiple"
    }
}

public struct BizumOperationMultiListInfoDTO: Codable {
    public let errorCode: String
}

struct BizumOperationMultiListContentDTO: Codable {
    let operations: [BizumOperationMultiDTO]
    
    private enum CodingKeys: String, CodingKey {
        case operations = "operaciones"
    }
}
