import Fuzi

public class XmlStubResponse {
    
    let serviceName: String
    let responseNumber: Int
    
    public init(for serviceName: String, response: Int = 0) {
        self.serviceName = serviceName
        self.responseNumber = response
    }
    
    public func response() -> String? {
        let filePath = Bundle(for: XmlStubResponse.self).path(forResource: "stub_" + self.serviceName, ofType: "xml")!
        let xml = try! String(contentsOfFile: filePath)
        let document = try! XMLDocument(string: xml)
        return document.root?.firstChild(tag: "id12345678z")?.firstChild(tag: "respuesta\(responseNumber)")?.children.first?.rawXML
    }
}
