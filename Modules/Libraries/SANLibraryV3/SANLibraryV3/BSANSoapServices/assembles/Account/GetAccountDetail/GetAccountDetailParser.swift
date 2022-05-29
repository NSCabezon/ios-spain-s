import Foundation

import Fuzi

public class GetAccountDetailParser : BSANParser <GetAccountDetailResponse, GetAccountDetailHandler> {
    override func setResponseData(){
        response.accountDetailDTO = handler.accountDetailDTO
    }
}

public class GetAccountDetailHandler: BSANHandler {
    
    var accountDetailDTO = AccountDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else {
            return
        }
        switch tag {
        case "fechaUltimaActualiza":
            accountDetailDTO.lastUpdate = DateFormats.safeDate(element.stringValue)
        case "fechaActualValoracion":
            accountDetailDTO.currentValueDate = DateFormats.safeDate(element.stringValue)
        case "fechaAltaBDP":
            accountDetailDTO.bdpEnrollmentDate = DateFormats.safeDate(element.stringValue)
        case "indicadorLibreta":
            accountDetailDTO.notebookIndicator = DTOParser.safeBoolean(element.stringValue)
        case "indicadorTalonarioAsoc":
            accountDetailDTO.counterfoilBookIndicator = DTOParser.safeBoolean(element.stringValue.trim())
        case "porcentajeContratos":
            accountDetailDTO.contractsPercentage = element.stringValue.trim()
        case "nombreProducto":
            accountDetailDTO.productName = element.stringValue.trim()
        case "titular":
            accountDetailDTO.holder = element.stringValue.trim()
        case "IBAN":
            accountDetailDTO.iban = IBANDTO(ibanString: element.stringValue.trim())
        case "importeSaldo":
            accountDetailDTO.balance = AmountDTOParser.parse(element)
        case "importeReal":
            accountDetailDTO.realAmount = AmountDTOParser.parse(element)
        case "importeDescubierto":
            accountDetailDTO.overdraftAmount = AmountDTOParser.parse(element)
        case "importeSaldoDisponible":
            accountDetailDTO.availableAmount = AmountDTOParser.parse(element)
        case "importeCredito":
            accountDetailDTO.creditAmount = AmountDTOParser.parse(element)
        case "importePdteConsolidar":
            accountDetailDTO.pendingConsolidationAmount = AmountDTOParser.parse(element)
        case "importeRetenciones":
            accountDetailDTO.withholdingAmount = AmountDTOParser.parse(element)
        case "importeVac":
            accountDetailDTO.vacAmount = AmountDTOParser.parse(element)
        case "importeContigencia":
            accountDetailDTO.contingencyAmount = AmountDTOParser.parse(element)
        case "importeLimiteSuperior":
            accountDetailDTO.upperLimitAmount = AmountDTOParser.parse(element)
        case "importeMaxTramo":
            accountDetailDTO.sectionMaxAmount = AmountDTOParser.parse(element)
        case "importeVolCesionesEstimado":
            accountDetailDTO.estimatedAssignmentsVolume = AmountDTOParser.parse(element)
        default:
            BSANLogger.e("\(#function)", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}


