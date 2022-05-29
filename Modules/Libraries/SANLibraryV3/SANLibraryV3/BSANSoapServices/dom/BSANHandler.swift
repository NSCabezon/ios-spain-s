import Foundation
import Fuzi

public class BSANHandler {

    var LOG_TAG: String {
        return String(describing: type(of: self))
    }
    
    let reposControl = ReposControl()
    var infoDTO: InfoDTO!

    required public init(){
        
    }
    
    func parse(data: String) throws {
        if let document = try? XMLDocument(string: data) {
            if let body = document.root?.firstChild(tag: "Body") {
                infoDTO = InfoDTO()
                let response = body.children[0]
                if response.tag?.uppercased() != "FAULT" && response.tag?.uppercased() != "ERROR" {
                    let result: XMLElement? = getResultBody(response)
                    if let result = result {
                        if let errorCode = findChild(node: result, childName: "errorCode"), errorCode.stringValue.trim() != "0" {
                            infoDTO?.errorCode = errorCode.stringValue
                            if let errorDesc = findChild(node: result, childName: "errorDesc") {
                                infoDTO?.errorDesc = errorDesc.stringValue.trim()
                            }
                            try parseResult(result: result)

                        } else {
                            parseReposControl(methodResult: result)
                            try parseResult(result: result)
                        }
                        
                    } else {
                        throw ParserException("No se encontro nodo methodResult")
                    }
                } else {
                    try parseFaultResult(faultResult: response)
                }
            } else {
                throw ParserException("No hay body")
            }
        } else {
            throw ParserException("No se pudo convertir respuesta a XMLDocument")
        }
    }


    internal func getResultBody (_ response: XMLElement) -> XMLElement? {
        
        if response.children.count == 1 {
            return response.children[0]
        }
        
        if let result = response.firstChild(tag: "methodResult") {
            return result
        }
        
        return response
    }
    
    func parseResult(result: XMLElement) throws {
        for element in result.children {
            try parseElement(element: element)
        }
    }
    
    func parseElement(element: XMLElement) throws {
    }

    internal func parseReposControl(methodResult: XMLElement) {

        if let finLista = methodResult.firstChild(tag: "finLista") {
            reposControl.finLista = DTOParser.safeBoolean(finLista.stringValue)
        }

        if let repos = methodResult.firstChild(tag: "repos") {
            if let clavePaginacion = repos.firstChild(tag: "clavePaginacion") {
                reposControl.clavePaginacion = clavePaginacion.stringValue.trim()
            }
            if let indRepos = repos.firstChild(tag: "indRepos") {
                reposControl.indRepos = indRepos.stringValue.trim()
            }
        }

        if let info = methodResult.firstChild(tag: "info") {

            if let codInfo = info.firstChild(tag: "codInfo") {
                infoDTO?.codInfo = codInfo.stringValue.trim()
            }

            if let errorDesc = info.firstChild(tag: "errorDesc") {
                infoDTO?.errorDesc = errorDesc.stringValue.trim()
            }
            if let errorCode = info.firstChild(tag: "errorCode") {
                infoDTO?.errorCode = errorCode.stringValue.trim()
            }
        }
    }

    internal func parseFaultResult(faultResult: XMLElement) throws {

        infoDTO?.fault = true

        if let faultCode = faultResult.firstChild(tag: "faultcode") {
            let faultCode = faultCode.stringValue.trim().lowercased()
            if ((faultCode.contains("invalidsecurity") || faultCode.contains("failedauthentication"))) {
                throw BSANUnauthorizedException("No autorizado")
            }
        }
        if let errorDesc = findChild(node: faultResult, childName: "desError") {
            infoDTO?.errorDesc = errorDesc.stringValue.trim()
        }
        if let errorDesc = findChild(node: faultResult, childName: "errorDesc") {
            infoDTO?.errorDesc = errorDesc.stringValue.trim()
        }
        if let errorDesc = findChild(node: faultResult, childName: "mensajeError") {
            infoDTO?.errorDesc = errorDesc.stringValue.trim()
        }
        if let errorCode = findChild(node: faultResult, childName: "errorCode") {
            infoDTO?.errorCode = errorCode.stringValue.trim()
        } else if let errorCode = findChild(node: faultResult, childName: "codError") {
            infoDTO?.errorCode = errorCode.stringValue.trim()
        }
        if infoDTO?.errorDesc == nil, let codError = findChild(node: faultResult, childName: "codError"){
            infoDTO?.errorDesc = codError.stringValue.trim()
        }
        if let messageByDefault = findChild(node: faultResult, childName: "messageByDefault") {
            infoDTO?.errorDesc = messageByDefault.stringValue.trim()
        }
        if infoDTO?.errorDesc == nil, let mensaje = findChild(node: faultResult, childName: "mensaje") {
            infoDTO?.errorDesc = mensaje.stringValue.trim()
        }
        if  infoDTO?.errorDesc == nil, let mensaje = findChild(node: faultResult, childName: "errorDesc") {
            infoDTO?.errorDesc = mensaje.stringValue.trim()
        }
        if let errorCode = findChild(node: faultResult, childName: "codigoError") {
            infoDTO?.errorCode = errorCode.stringValue.trim()
        }
        if let errorDesc = findChild(node: faultResult, childName: "descripcionError") {
            infoDTO?.errorDesc = errorDesc.stringValue.trim()
        }
        if infoDTO?.errorDesc == nil, let message = findChild(node: faultResult, childName: "message") {
            infoDTO?.errorDesc = message.stringValue.trim()
        }
        if infoDTO?.errorCode == nil, let errorCode = findChild(node: faultResult, childName: "codigo") {
            infoDTO?.errorCode = errorCode.stringValue.trim()
        }
    }
    
    private func findChild(node: XMLElement, childName: String) -> XMLElement?{
        if let child = node.firstChild(tag: childName){
            return child
        }
        else{
            if node.children.count > 0{
                for childNode in node.children{
                    if let foundChild = findChild(node: childNode, childName: childName){
                        return foundChild
                    }
                }
            }
        }
        
        return nil
    }
}
