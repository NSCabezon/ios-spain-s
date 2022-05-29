import Foundation
import Fuzi

public class GetHolderDetailParser : BSANParser <GetHolderDetailResponse, GetHolderDetailHandler> {
    override func setResponseData(){
        response.holders = handler.holders
    }
}

public class GetHolderDetailHandler: BSANHandler {
    
    var holders = [HolderDTO]()
    
    override func parseElement(element: XMLElement) throws {
        
        guard let tag = element.tag else { return }
        switch tag {
        case "lista":

            if element.children(tag: "dato").count == 0{
                break
            }

            for i in 0 ... element.children(tag: "dato").count-1{
                let childElement = element.children(tag: "dato")[i]
                
                var newHolder = HolderDTO()
                
                if let nombre = childElement.firstChild(tag: "nombre"){
                    newHolder.name = nombre.stringValue.trim()
                }
                if let descTipoIntervencion = childElement.firstChild(tag: "descTipoIntervencion"){
                    newHolder.ownershipTypeDesc = OwnershipTypeDesc.findBy(type: descTipoIntervencion.stringValue.trim())
                }

                holders.append(newHolder)
            }

        default:
            BSANLogger.e("\(String.init(describing: self))", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
