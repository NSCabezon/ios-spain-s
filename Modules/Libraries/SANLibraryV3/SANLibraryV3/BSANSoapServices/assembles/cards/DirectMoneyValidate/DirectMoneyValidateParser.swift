import Foundation
import Fuzi

public class DirectMoneyValidateParser : BSANParser <DirectMoneyValidateResponse, DirectMoneyValidateHandler> {
    override func setResponseData(){
        response.directMoneyValidatedDTO = handler.directMoneyValidatedDTO
    }
}

public class DirectMoneyValidateHandler: BSANHandler {
    
    var directMoneyValidatedDTO = DirectMoneyValidatedDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        if let datosFirma = result.firstChild(tag: "datosFirma"){
            directMoneyValidatedDTO.signature = SignatureDTOParser.parse(datosFirma)
        }

        let directMoneyDTO = DirectMoneyDTOParser.parse(result)
        directMoneyValidatedDTO.linkedAccountCheckDigits = directMoneyDTO.linkedAccountCheckDigits
        directMoneyValidatedDTO.linkedAccountBank = directMoneyDTO.linkedAccountBank
        directMoneyValidatedDTO.linkedAccountBranch = directMoneyDTO.linkedAccountBranch
        directMoneyValidatedDTO.linkedAccountNumber = directMoneyDTO.linkedAccountNumber
        directMoneyValidatedDTO.holder = directMoneyDTO.holder
        directMoneyValidatedDTO.availableAmount = directMoneyDTO.availableAmount
        directMoneyValidatedDTO.cardTypeDescription = directMoneyDTO.cardTypeDescription
        directMoneyValidatedDTO.minAmountDescription = directMoneyDTO.minAmountDescription
        directMoneyValidatedDTO.cardNumber = directMoneyDTO.cardNumber
        directMoneyValidatedDTO.cardDescription = directMoneyDTO.cardDescription
        directMoneyValidatedDTO.cardContractStatusDesc = directMoneyDTO.cardContractStatusDesc
    }
}
