import Foundation

public struct BizumOperationMultipleListDetailDTO: Codable {
    public let info: BizumOperationMultipleListDetailInfoDTO?
    public let accepted: Int?
    public let pending: Int?
    public let notAccepted: Int?
    public let opeartionId: String?
    public let concept: String?
    public let amount: Double?
    public let elementsTotal: Int?
    public let emitterId: String?
    public let emitterAlias: String?
    public let emitterIban: BizumIbanDTO?
    public let dischargeDate: Date?
    public let type: String?
    private let operationList: BizumOperationMultipleListDetailContentDTO
    public var operations: [BizumOperationMultipleDetailDTO] {
        return operationList.operations
    }
    
    private enum CodingKeys: String, CodingKey {
        case info
        case accepted = "numeroAceptadas"
        case pending = "numeroPendientes"
        case notAccepted = "numeroNoAceptadas"
        case opeartionId = "idOperacionMultiple"
        case concept = "concepto"
        case amount = "importe"
        case elementsTotal = "numTotalOperaciones"
        case emitterId = "idUsuEmisor"
        case emitterAlias = "aliasEmisor"
        case emitterIban = "ibanEmisor"
        case dischargeDate = "fechaHoraAlta"
        case type = "tipoOperacion"
        case operationList = "listaOperaciones"
    }
}
public struct BizumOperationMultipleListDetailInfoDTO: Codable {
    public let errorCode: String
}

struct BizumOperationMultipleListDetailContentDTO: Codable {
    let operations: [BizumOperationMultipleDetailDTO]
    
    private enum CodingKeys: String, CodingKey {
        case operations = "operaciones"
    }
}

extension BizumOperationMultipleListDetailDTO: DateParseable {
    public static var formats: [String: String] {
        return [
            "fechaHoraAlta": "yyyy-MM-dd HH:mm:ss:SSS"
        ]
    }
}
