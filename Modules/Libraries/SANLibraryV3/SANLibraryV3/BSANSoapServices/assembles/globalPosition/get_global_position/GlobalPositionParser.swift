import Foundation
import Fuzi

public class GlobalPositionParser : BSANParser<GlobalPositionResponse, GlobalPositionHandler> {
    override func setResponseData(){
         response.globalPositionDTO = handler.globalPositionDTO
    }
}

public class GlobalPositionHandler: BSANHandler {
    
    var globalPositionDTO =  GlobalPositionDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "datosUsuario":
            globalPositionDTO.userDataDTO = UserDataDTOParser.parse(element)
            break
        case "cuentas":
            globalPositionDTO.accounts = AccountsDTOParser.parse(element)
            break
        case "tarjetas":
            globalPositionDTO.cards = CardsDTOParser.parse(element)
            break
        case "fondos":
            globalPositionDTO.funds = FundsDTOParser.parse(element)
            break
        case "depositos":
            globalPositionDTO.deposits = DepositsDTOParser.parse(element)
            break
        case "planes":
            globalPositionDTO.pensions = PensionsDTOParser.parse(element)
            break
        case "prestamos":
            globalPositionDTO.loans = LoansDTOParser.parse(element)
            break
        case "valores":
            globalPositionDTO.stockAccounts = StockAccountsDTOParser.parse(element)
            break
        case "seguros":
            globalPositionDTO.savingsInsurances = InsurancesDTOParser.parse(element)
            break
        case "otrosSeguros":
            globalPositionDTO.protectionInsurances = InsurancesDTOParser.parse(element)
            break
        case "nombreCliente":
            globalPositionDTO.clientName = element.stringValue.trim()
            break
        case "nombrePersonaSinApellidos":
            globalPositionDTO.clientNameWithoutSurname = element.stringValue.trim()
            break
        case "apellidoUno":
            globalPositionDTO.clientFirstSurname = SurNameDTOParser.parse(element)
            break
        case "apellidoDos":
            globalPositionDTO.clientSecondSurname = SurNameDTOParser.parse(element)
            break
        case "fechaNacimientoCliente":
            globalPositionDTO.clientBirthDate = DateFormats.safeDate(element.stringValue)
            break
        case "indMigradoSEPA":
            globalPositionDTO.sepaMigratedInd = DTOParser.safeBoolean(element.stringValue.trim())
            break
        case "indMigradoDeBanesto":
            globalPositionDTO.banestoMigratedInd = DTOParser.safeBoolean(element.stringValue.trim())
            break
        case "info":
            break
        default:
            BSANLogger.e("GlobalPositionParser", "Nodo Sin Parsear! -> \(tag)")
            break
        }
        
    }
    
}
