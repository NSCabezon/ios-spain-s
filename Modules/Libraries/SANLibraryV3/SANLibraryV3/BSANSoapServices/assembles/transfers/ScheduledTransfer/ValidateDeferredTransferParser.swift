import Foundation
import Fuzi

public class ValidateDeferredTransferParser : BSANParser<ValidateDeferredTransferResponse, ValidateDeferredTransferHandler> {
    override func setResponseData(){
        response.validateDeferredTransferDTO = handler.validateDeferredTransferDTO
    }
}

public class ValidateDeferredTransferHandler: BSANHandler {
    
    var validateDeferredTransferDTO = ValidateScheduledTransferDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        if let actuanteCode = result.firstChild(tag: "codigoActuante") {
            validateDeferredTransferDTO.actuanteNumber = actuanteCode.firstChild(tag: "NUMERO_DE_ACTUANTE")?.stringValue
            if let actuanteType = actuanteCode.firstChild(tag: "TIPO_DE_ACTUANTE") {
                validateDeferredTransferDTO.actuanteCompany = actuanteType.firstChild(tag: "EMPRESA")?.stringValue
                validateDeferredTransferDTO.actuanteCode = actuanteType.firstChild(tag: "COD_TIPO_DE_ACTUANTE")?.stringValue
            }
        }
        
        if let totalCommission = result.firstChild(tag: "totalComisiones") {
            validateDeferredTransferDTO.commission = AmountDTOParser.parse(totalCommission)
        }
        
        if let serTuBancoBelongs = result.firstChild(tag: "perteneceSerTuBanco")?.stringValue {
            validateDeferredTransferDTO.serTuBancoBelongs = serTuBancoBelongs
        }
        
        if let nameBeneficiaryBank = result.firstChild(tag: "nombreBancoIbanBeneficiario")?.stringValue {
            validateDeferredTransferDTO.nameBeneficiaryBank = nameBeneficiaryBank
        }
        
        var signatureDTO = SignatureDTOParser.parse(result)
        signatureDTO.length = DTOParser.safeInteger(result.firstChild(tag: "tamanoFirma")?.stringValue)
        validateDeferredTransferDTO.scaRepresentable = SignatureAndOTP(signature: signatureDTO)
        validateDeferredTransferDTO.dataMagicPhrase = result.firstChild(tag: "dataToken")?.stringValue
    }
}
