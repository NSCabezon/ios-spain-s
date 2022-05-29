import Foundation
import Fuzi

public class UserSegmentParser : BSANParser<UserSegmentResponse, UserSegmentHandler> {
    override func setResponseData(){
        response.userSegmentDTO = handler.userSegmentDTO
    }
}

public class UserSegmentHandler: BSANHandler {
    
    var userSegmentDTO: UserSegmentDTO = UserSegmentDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "segmentoBDP":
            userSegmentDTO.bdpSegment = SegmentDTOParser.parse(element)
            break
        case "segmentoComercial":
            userSegmentDTO.commercialSegment = SegmentDTOParser.parse(element)
            break
        case "indColectivoS":
            userSegmentDTO.indCollectiveS = DTOParser.safeBoolean(element.stringValue)
            break
        case "indColectivoRenunAcc":
            userSegmentDTO.indColectivoRenunAcc = DTOParser.safeBoolean(element.stringValue)
            break
        case "indColectivoCarenciaOGracia":
            userSegmentDTO.indColectivoCarenciaOGracia = DTOParser.safeBoolean(element.stringValue)
            break
        case "indColectivoSAutonomo":
            userSegmentDTO.indCollectiveSFreelance = DTOParser.safeBoolean(element.stringValue)
            break
        case "indColectivoSEmpresas":
            userSegmentDTO.indCollectiveSCompanies = DTOParser.safeBoolean(element.stringValue)
            break
        case "colectivoJuzgados":
            userSegmentDTO.colectivoJuzgados = DTOParser.safeBoolean(element.stringValue)
            break
        case "colectivo123Smart":
            userSegmentDTO.colectivo123Smart = DTOParser.safeBoolean(element.stringValue)
            break
        case "colectivo123SmartFree":
            userSegmentDTO.colectivo123SmartFree = DTOParser.safeBoolean(element.stringValue)
            break
		case "colectivoAutonomoPrem":
			userSegmentDTO.colectivoAutonomoPrem = DTOParser.safeBoolean(element.stringValue)
			break
		case "colectivoAutonomoFree":
			userSegmentDTO.colectivoAutonomoFree = DTOParser.safeBoolean(element.stringValue)
			break
        default:
            BSANLogger.e("UserSegmentParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
    
}
