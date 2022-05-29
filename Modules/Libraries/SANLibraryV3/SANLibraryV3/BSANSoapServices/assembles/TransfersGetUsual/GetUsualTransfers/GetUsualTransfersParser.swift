import Foundation
import Fuzi

public class GetUsualTransfersParser : BSANParser<GetUsualTransfersResponse, GetUsualTransfersHandler> {
    override func setResponseData(){
        response.payeeDTOs = handler.payeeDTOs
        response.paginationDTO = handler.paginationDTO
    }
}

public class GetUsualTransfersHandler: BSANHandler {
    var payeeDTOs: [PayeeDTO] = []
    var paginationDTO: PaginationDTO?
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "lista":
            payeeDTOs = PayeeDTOsParser.parse(element)
            break
        case "paginacion":
            paginationDTO = PaginationDTO()
            paginationDTO?.repositionXML = element.description.replace("<indicador>S</indicador>", "<indicador>N</indicador>")
            if let indicador = element.firstChild(tag: "indicador") {
                paginationDTO?.endList = indicador.stringValue.trim().lowercased() == "n"
            }
            break
        default:
            BSANLogger.e("GetUsualTransfersParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
