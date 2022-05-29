import Foundation
import Fuzi

public class ValidateUsualTransferParser : BSANParser <ValidateUsualTransferResponse, ValidateUsualTransferHandler> {
    override func setResponseData(){
        response.validateAccountTransferDTO = handler.validateAccountTransferDTO
    }
}

public class ValidateUsualTransferHandler: BSANHandler {
    
    var validateAccountTransferDTO = ValidateAccountTransferDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        if let datos = result.firstChild(tag: "datosBasicosYFirma"){
            if let datosBasicos = datos.firstChild(tag: "datosBasicos") {
                validateAccountTransferDTO.transferNationalDTO = TransferNationalDTOParser.parse(datosBasicos)
            }
            if let datosFirma = datos.firstChild(tag: "datosFirma") {
                validateAccountTransferDTO.transferNationalDTO?.scaRepresentable = SignatureAndOTP(signature: SignatureDTOParser.parse(datosFirma))
            }
        }
        
        if let info = result.firstChild(tag: "info") {
            validateAccountTransferDTO.errorCode = info.firstChild(tag: "errorDesc")?.stringValue
        }
    }
}
