public struct BizumOperationListDTO: Codable {
    public let info: BizumOperationListInfoDTO
    public let elementsTotal: Int?
    public let pagesTotal: Int?
    public let moreData: String
    public var operations: [BizumOperationDTO] {
        return operationList.operations
    }
    private let operationList: BizumOperationListOperationsDTO

    private enum CodingKeys: String, CodingKey {
        case info
        case elementsTotal = "numeroTotalElementos"
        case pagesTotal = "numeroTotalpaginas"
        case moreData = "masDatos"
        case operationList = "operaciones"
    }
}

public struct BizumOperationListInfoDTO: Codable {
    public let errorCode: String
}

struct BizumOperationListOperationsDTO: Codable {
    let operations: [BizumOperationDTO]
    
    private enum CodingKeys: String, CodingKey {
        case operations = "operaciones"
    }
}

extension BizumOperationListDTO: DateParseable {
    public static var formats: [String: String] {
        return [
            "operaciones.operaciones.fechaHoraAlta": "yyyy-MM-dd HH:mm:ss:SSS",
            "operaciones.operaciones.fechaHoraModif": "yyyy-MM-dd HH:mm:ss:SSS",
            "operaciones.operaciones.listaAcciones.accionDisponible.fechaCaducidad": "yyyy-MM-dd HH:mm:ss:SSS"
        ]
    }
}
