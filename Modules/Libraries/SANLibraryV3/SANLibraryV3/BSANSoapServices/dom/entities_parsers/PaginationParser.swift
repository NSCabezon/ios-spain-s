import Foundation
import Fuzi

class PaginationParser: DTOParser {
    
    public static  func parse(_ node: XMLElement) -> PaginationDTO {
        var pagination = PaginationDTO()
        
        if let finLista = node.firstChild(tag: "finLista"){
            pagination.endList = DTOParser.safeBoolean(finLista.stringValue.trim())
        }
        
        if let finLista = node.firstChild(tag: "finListado"){
            pagination.endList = DTOParser.safeBoolean(finLista.stringValue.trim())
        }
        
        if let importeCta = node.firstChild(tag: "importeCta"){
            pagination.accountAmountXML = importeCta.rawXML.trim()
        }
        
        if let repo = node.firstChild(tag: "repo"){
            pagination.repositionXML = repo.rawXML.trim()
        }
        
        if let repo = node.firstChild(tag: "repos"){
            pagination.repositionXML = repo.rawXML.trim()
        }
        
        if let repo = node.firstChild(tag: "reposicionamiento"){
            pagination.repositionXML = repo.rawXML.trim().replace("reposicionamiento", "repos")
            pagination.endList = repo.firstChild(tag: "indMasDatMisPag")?.stringValue == "N"
        }
        
        if let repo = node.firstChild(tag: "datosPaginacion") {
            let paginationTemp = repo.rawXML.trim()
            pagination.repositionXML = paginationTemp.replace("datosPaginacion", "paginacion")
        }
        
        if let repo = node.firstChild(tag: "paginacion") {
            pagination.repositionXML = repo.rawXML.trim()
        }
        
        return pagination
    }
}
