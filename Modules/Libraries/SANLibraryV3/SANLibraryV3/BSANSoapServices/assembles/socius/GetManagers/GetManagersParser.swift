import Foundation
import Fuzi

public class GetManagersParser : BSANParser <GetManagersResponse, GetManagersHandler> {
    override func setResponseData(){
        response.yourManagersListDTO = handler.yourManagersListDTO
    }
}

public class GetManagersHandler: BSANHandler {
    
    var yourManagersListDTO = YourManagersListDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
            
        case "gestores":
            
            var managerDTO = ManagerDTO()
            if let codGest = element.firstChild(tag: "codGest"){
                managerDTO.codGest = codGest.stringValue.trim()
            }
            if let nombreGest = element.firstChild(tag: "nombreGest"){
                managerDTO.nameGest = nombreGest.stringValue.trim()
            }
            if let categoria = element.firstChild(tag: "categoria"){
                managerDTO.category = categoria.stringValue.trim()
            }
            if let cartera = element.firstChild(tag: "cartera"){
                managerDTO.portfolio = cartera.stringValue.trim()
            }
            if let desTipCater = element.firstChild(tag: "desTipCater"){
                managerDTO.desTipCater = desTipCater.stringValue.trim()
            }
            if let telefono = element.firstChild(tag: "telefono"){
                managerDTO.phone = telefono.stringValue.trim()
            }
            if let mail = element.firstChild(tag: "mail"){
                managerDTO.email = mail.stringValue.trim()
            }
            if let indPrioridad = element.firstChild(tag: "indPrioridad"){
                managerDTO.indPriority = DTOParser.safeInteger(indPrioridad.stringValue.trim())
            }
            if let tipoCartera = element.firstChild(tag: "tipoCartera"){
                managerDTO.portfolioType = tipoCartera.stringValue.trim()
            }
            
            yourManagersListDTO.managerList.append(managerDTO)
            
            break
            
        default:
            BSANLogger.e("GetManagersHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
    
}
