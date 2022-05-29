import Foundation
import Fuzi

class SignatureDataDTOParser: DTOParser {
    
    public static  func parse(_ node: XMLElement) -> SignatureDataDTO {
        var signatureData = SignatureDataDTO()
        
        if let lista = node.firstChild(tag: "lista"){
            signatureData.list = SignatureUserItemDTOsParser.parse(lista)
        }
        
        if let indActividadEstadoFirma = node.firstChild(tag: "indActividadEstadoFirma"){
            signatureData.signatureActivityStatusInd = indActividadEstadoFirma.stringValue.trim()
        }
        
        if let indFaseEstadoFirma = node.firstChild(tag: "indFaseEstadoFirma"){
            signatureData.signaturePhaseStatusInd = indFaseEstadoFirma.stringValue.trim()
        }
        
        return signatureData
    }
}
