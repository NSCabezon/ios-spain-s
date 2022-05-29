import Foundation
import Fuzi

public class BlockCardConfirmationParser : BSANParser <BlockCardConfirmationResponse, BlockCardConfirmationHandler> {
    override func setResponseData(){
        response.blockCardConfirmDTO = handler.blockCardConfirmDTO
    }
}

public class BlockCardConfirmationHandler: BSANHandler {
    
    var blockCardConfirmDTO = BlockCardConfirmDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let direccionEnvio = result.firstChild(tag: "direccionEnvio") {
            blockCardConfirmDTO.deliveryAddress = direccionEnvio.stringValue.trim()
        }
        
        if let horaBloqueo = result.firstChild(tag: "horaBloqueo") {
            blockCardConfirmDTO.blockTime = DateFormats.safeTime(horaBloqueo.stringValue)
        }
    }
}
