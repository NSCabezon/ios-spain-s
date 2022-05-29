import Foundation
import Fuzi

public class BlockCardParser : BSANParser <BlockCardResponse, BlockCardHandler> {
    override func setResponseData(){
        response.blockCardDTO = handler.blockCardDTO
    }
}

public class BlockCardHandler: BSANHandler {
    
    var blockCardDTO = BlockCardDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
            
        case "datosFirma":
            blockCardDTO.signature = SignatureDTOParser.parse(element)
        default:
            BSANLogger.e("BlockCardHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
