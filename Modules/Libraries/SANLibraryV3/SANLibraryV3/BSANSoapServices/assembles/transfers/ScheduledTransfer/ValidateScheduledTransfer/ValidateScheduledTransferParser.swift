import Foundation
import Fuzi

public class ValidateScheduledTransferParser : BSANParser<ValidateScheduledTransferResponse, ValidateScheduledTransferHandler> {
    override func setResponseData(){
        response.validateScheduledTransferDTO = handler.validateScheduledTransferDTO
    }
}

public class ValidateScheduledTransferHandler: BSANHandler {
    
    var validateScheduledTransferDTO = ValidateScheduledTransferDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        if let actuanteCode = result.firstChild(tag: "codigoActuante") {
            validateScheduledTransferDTO.actuanteNumber = actuanteCode.firstChild(tag: "NUMERO_DE_ACTUANTE")?.stringValue
            if let actuanteType = actuanteCode.firstChild(tag: "TIPO_DE_ACTUANTE") {
                validateScheduledTransferDTO.actuanteCompany = actuanteType.firstChild(tag: "EMPRESA")?.stringValue
                validateScheduledTransferDTO.actuanteCode = actuanteType.firstChild(tag: "COD_TIPO_DE_ACTUANTE")?.stringValue
            }
        }
        
        if let totalCommission = result.firstChild(tag: "totalComisiones") {
            validateScheduledTransferDTO.commission = AmountDTOParser.parse(totalCommission)
        }
        
        validateScheduledTransferDTO.serTuBancoBelongs = result.firstChild(tag: "perteneceSerTuBanco")?.stringValue
        validateScheduledTransferDTO.nameBeneficiaryBank = result.firstChild(tag: "nombreBancoIbanBeneficiario")?.stringValue
        
        var signatureDTO = SignatureDTOParser.parse(result)
        signatureDTO.length = DTOParser.safeInteger(result.firstChild(tag: "tamanoFirma")?.stringValue)
        validateScheduledTransferDTO.scaRepresentable = SignatureAndOTP(signature: signatureDTO)
        validateScheduledTransferDTO.dataMagicPhrase = result.firstChild(tag: "dataToken")?.stringValue
    }
}
