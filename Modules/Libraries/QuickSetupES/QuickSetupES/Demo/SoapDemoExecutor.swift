import Fuzi
import SANLibraryV3

class SoapDemoExecutor: SoapServiceExecutor {

    let demoInterpreter: DemoInterpreter
    
    init(demoInterpreter: DemoInterpreter) {
        self.demoInterpreter = demoInterpreter
    }

    func executeCall<Params, Response, Handler, Parser, Request>(request: Request) throws -> String where Request: BSANSoapRequest<Params, Handler, Response, Parser> {

        var xmlToParse = ""

        if let filepath = Bundle(for: SoapDemoExecutor.self).path(forResource: request.serviceName, ofType: "xml") {
            do {
                xmlToParse = try String(contentsOfFile: filepath)
            } catch {
                return ""
            }
        } else {
            return ""
        }
        
        guard let document = try? XMLDocument(string: xmlToParse), let filtered = getAnswers(document: document) else {
            return ""
        }
        
        let answerNumber = demoInterpreter.getAnswerNumber(serviceName: request.serviceName)
        
        if answerNumber < filtered.children.count {
            return filtered.children[answerNumber].children[0].rawXML
        }

        return ""
    }
    
    // By Default, we try to use specific user answer. In case it does not exist, we fall back the default demo user answer
    func getAnswers(document: XMLDocument) -> XMLElement? {
        if let demoUserId = demoInterpreter.getDemoUser(), let filtered = document.root?.firstChild(tag: "id\(demoUserId)") {
            return filtered
        } else {
            return document.root?.firstChild(tag: "id\(demoInterpreter.getDefaultDemoUser())")
        }
    }

    var logTag: String {
        return String(describing: type(of: self))
    }
}
