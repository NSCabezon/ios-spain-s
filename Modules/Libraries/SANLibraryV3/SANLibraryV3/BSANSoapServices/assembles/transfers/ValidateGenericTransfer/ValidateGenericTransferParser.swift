import Foundation
import Fuzi

public class ValidateGenericTransferParser : BSANParser <ValidateGenericTransferResponse, ValidateGenericTransferHandler> {
    override func setResponseData() {
        response.validateAccountTransferDTO = handler.validateAccountTransferDTO
    }
}

public class ValidateGenericTransferHandler: BSANHandler {
    
    var validateAccountTransferDTO = ValidateAccountTransferDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        if let datos = result.firstChild(tag: "datosBasicosYFirma") {
            if let datosBasicos = datos.firstChild(tag: "datosBasicos") {
                validateAccountTransferDTO.transferNationalDTO = TransferNationalDTOParser.parse(datosBasicos)
            }
            if let datosFirma = datos.firstChild(tag: "datosFirma") {
                validateAccountTransferDTO.transferNationalDTO?.scaRepresentable = SignatureAndOTP(signature: SignatureDTOParser.parse(datosFirma))
            }
        }
        if let indicadorHuella = result.firstChild(tag: "indicadorHuella") {
            validateAccountTransferDTO.transferNationalDTO?.fingerPrintFlag = indicadorHuella.stringValue.lowercased() == "s" ? .biometry : .signature
        }
        if let tokenPasos = result.firstChild(tag: "tokenPasos") {
            validateAccountTransferDTO.transferNationalDTO?.tokenSteps = tokenPasos.stringValue
        }
        
        if let info = result.firstChild(tag: "info") {
            validateAccountTransferDTO.errorCode = info.firstChild(tag: "errorDesc")?.stringValue
        }
    }
}
