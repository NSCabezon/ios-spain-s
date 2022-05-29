import Foundation
import Fuzi

class FundSubscriptionDTOParser: DTOParser {
    
    public static  func parse(_ node: XMLElement) -> FundSubscriptionDTO {
        var fundSubscriptionDTO = FundSubscriptionDTO()
        
        if let tokenPasos = node.firstChild(tag: "tokenPasos"){
            fundSubscriptionDTO.tokenPasos = tokenPasos.stringValue.trim()
        }
        
        if let nombreTitular = node.firstChild(tag: "nombreTitular"){
            fundSubscriptionDTO.holderName = nombreTitular.stringValue.trim()
        }

        if let ctaDomiciliacionIBAN = node.firstChild(tag: "ctaDomiciliacionIBAN"){
            fundSubscriptionDTO.directDebtAccount = IBANDTOParser.parse(ctaDomiciliacionIBAN)
        }

        if let accionMifid = node.firstChild(tag: "accionMifid"){
            fundSubscriptionDTO.mifidAction = InstructionStatusDTOParser.parse(accionMifid)
        }
        
        if let descFondo = node.firstChild(tag: "descFondo"){
            fundSubscriptionDTO.fundDescription = descFondo.stringValue.trim()
        }
        
        if let datosSalidaVal = node.firstChild(tag: "datosSalidaVal"){
            fundSubscriptionDTO.fundSubscriptionResponseData = FundSubscriptionResponseDataDTOParser.parse(datosSalidaVal)
        }
        
        if let descClausulaVar = node.firstChild(tag: "descClausulaVar"){
            fundSubscriptionDTO.varClauseDesc = descClausulaVar.stringValue.trim()
        }
        
        if let descClausulaObl = node.firstChild(tag: "descClausulaObl"){
            fundSubscriptionDTO.OblClauseDesc = descClausulaObl.stringValue.trim()
        }
        
        var lista = [FundMifidClauseDTO]()
        
        if let listaClausulas = node.firstChild(tag: "listaClausulas"){
            for element in listaClausulas.children {
                lista.append(FundMifidClauseDTOParser.parse(element))
            }
        }
        fundSubscriptionDTO.fundMifidClauseDataList = lista
        
        fundSubscriptionDTO.signature = SignatureDTOParser.parse(node)
        
        
        return fundSubscriptionDTO
    }
}
