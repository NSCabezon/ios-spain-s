import Foundation
import Fuzi

public class GetPersonDataListParser : BSANParser<GetPersonDataListResponse, GetPersonDataListHandler> {
    override func setResponseData(){
        response.personDataDTOs = handler.personDataDTOs
    }
}

public class GetPersonDataListHandler: BSANHandler {
    
    var personDataDTOs: [PersonDataDTO] = []
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "lista":
            personDataDTOs = PersonDataDTOsParser.parse(element)
            break
        case "datosConexion":
            break
        default:
            BSANLogger.e("GetPersonDataListParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
    
}
