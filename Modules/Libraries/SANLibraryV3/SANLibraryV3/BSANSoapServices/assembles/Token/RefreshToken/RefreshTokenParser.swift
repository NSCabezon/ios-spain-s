import Foundation
import Fuzi

public class RefreshTokenParser : BSANParser <RefreshTokenResponse, RefreshTokenHandler> {
    override func setResponseData(){
		response.tokenCredential = handler.tokenCredential
    }
}

public class RefreshTokenHandler: BSANHandler {
    
	var tokenCredential = String()
    
    override func parse(data: String) throws {
        if let document = try? XMLDocument(string: data) {
            if let body = document.root?.firstChild(tag: "Body") {
                infoDTO = InfoDTO()
                let response = body.children[0]
                if response.tag?.uppercased() != "FAULT" && response.tag?.uppercased() != "ERROR" {
                    let result: XMLElement? = getResultBody(response)
                    if let result = result {
                        try parseElement(element: result)
                    } else {
                        throw ParserException("No se encontro nodo methodResult")
                    }
                } else {
                    try parseFaultResult(faultResult: response)
                }
            } else {
                throw ParserException("No se encontro nodo Body")
            }
        } else {
            throw ParserException("No se pudo convertir respuesta a XMLDocument")
        }
    }
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
		case "methodResult":
			tokenCredential = element.stringValue.trim()
		case "soap-env:Fault":
			infoDTO = infoDTO?.setFault(fault: true)
        default:
           BSANLogger.e("RefreshTokenHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}

