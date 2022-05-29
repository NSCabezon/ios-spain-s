import Foundation

public struct BizumOperationDTO: Codable {
    public let operationId: String?
    public let emitterId: String?
    public let receptorId: String?
    public let emitterIban: BizumIbanDTO?
    public let receptorIban: BizumIbanDTO?
    public let type: String?
    public let amount: Double?
    public let concept: String?
    public let dischargeDate: Date?
    public let modificationDate: Date?
    public let state: String?
    public let emitterAlias: String?
    public let receptorAlias: String?
    public let actionList: BizumActionList?
    private let returnedFields: BizumOperationListField?
    public var fields: [String: String]? {
        self.returnedFields?.fields.filter {
            $0.field != nil && $0.value != nil
        }.reduce(into: [:], {
            $0[$1.field ?? ""] = $1.value
        })
    }
    
    //Temporally used for unit test
    init(operationId: String? = nil,
         emitterId: String? = nil,
         receptorId: String? = nil,
         emitterIban: BizumIbanDTO? = nil,
         receptorIban: BizumIbanDTO? = nil,
         type: String? = nil,
         amount: Double? = nil,
         concept: String? = nil,
         dischargeDate: Date? = nil,
         modificationDate: Date? = nil,
         state: String? = nil,
         emitterAlias: String? = nil,
         receptorAlias: String? = nil,
         returnedFields: BizumOperationListField? = nil) {
        self.operationId = operationId
        self.emitterId = emitterId
        self.receptorId = receptorId
        self.emitterIban = emitterIban
        self.receptorIban = receptorIban
        self.type = type
        self.amount = amount
        self.concept = concept
        self.dischargeDate = dischargeDate
        self.modificationDate = modificationDate
        self.state = state
        self.emitterAlias = emitterAlias
        self.receptorAlias = receptorAlias
        self.returnedFields = returnedFields
        self.actionList = nil
    }

    private enum CodingKeys: String, CodingKey {
        case operationId = "idOperacion"
        case emitterId = "idUsuEmisor"
        case receptorId = "idUsuReceptor"
        case emitterIban = "ibanEmisor"
        case receptorIban = "ibanReceptor"
        case type = "tipo"
        case amount = "importe"
        case concept = "concepto"
        case dischargeDate = "fechaHoraAlta"
        case modificationDate = "fechaHoraModif"
        case state = "estado"
        case emitterAlias = "aliasEmisor"
        case receptorAlias = "aliasReceptor"
        case actionList = "listaAcciones"
        case returnedFields = "camposDevueltos"
    }
}

struct BizumOperationListField: Codable {
    let fields: [BizumOperationField]
    
    private enum CodingKeys: String, CodingKey {
        case fields = "campos"
    }
}

struct BizumOperationField: Codable {
    let field: String?
    let value: String?

    private enum CodingKeys: String, CodingKey {
        case field = "campo"
        case value = "valor"
    }
}

// MARK: - ListaAcciones
public struct BizumActionList: Codable {
    public let availableAction: [BizumAvailableAction]
    
    private enum CodingKeys: String, CodingKey {
        case availableAction = "accionDisponible"
    }
}


public struct BizumAvailableAction: Codable {
    public let action: String
    public let expiry: Date
    
    private enum CodingKeys: String, CodingKey {
        case action = "tipoAccion"
        case expiry = "fechaCaducidad"
    }
}
