import Foundation
import Fuzi

public class ValidateFundTransferParser : BSANParser <ValidateFundTransferResponse, ValidateFundTransferHandler> {
    override func setResponseData(){
        response.fundTransferDTO = handler.fundTransferDTO
    }
}

public class ValidateFundTransferHandler: BSANHandler {
    
    var fundTransferDTO = FundTransferDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        fundTransferDTO.signature = SignatureDTOParser.parse(result)
        
        if let tokenPasos = result.firstChild(tag: "tokenPasos") {
            fundTransferDTO.tokenPasos = tokenPasos.stringValue.trim()
        }
        
        if let nombreTitular = result.firstChild(tag: "nombreTitular") {
            fundTransferDTO.holderName = nombreTitular.stringValue.trim()
        }
        
        if let ctaAsociada = result.firstChild(tag: "ctaAsociada") {
            fundTransferDTO.linkedAccount = IBANDTOParser.parse(ctaAsociada)
        }
        
        if let accionMifid = result.firstChild(tag: "accionMifid") {
            fundTransferDTO.mifidAction = InstructionStatusDTOParser.parse(accionMifid)
        }
        
        if let descFondo = result.firstChild(tag: "descFondo") {
            fundTransferDTO.fundDescription = descFondo.stringValue.trim()
        }
        
        if let datosSalidaVal = result.firstChild(tag: "datosSalidaVal") {
            fundTransferDTO.fundTransferResponseData = FundTransferResponseDataDTOParser.parse(datosSalidaVal)
        }
        
        if let descClausulaVar = result.firstChild(tag: "descClausulaVar") {
            fundTransferDTO.varClauseDesc = descClausulaVar.stringValue.trim()
        }
        
        if let descClausulaObl = result.firstChild(tag: "descClausulaObl") {
            fundTransferDTO.OblClauseDesc = descClausulaObl.stringValue.trim()
        }
    }
}
