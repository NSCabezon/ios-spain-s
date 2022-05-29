
import SanLibraryV3
import Fuzi

class SoapDemoExecutor: SoapServiceExecutor {

    var bsanDataProvider: BSANDataProvider

    var logTag: String {
        return String(describing: type(of: self))
    }
    
    public init(bsanDataProvider: BSANDataProvider) {
        self.bsanDataProvider = bsanDataProvider
    }

    func executeCall<Params, Response, Handler, Parser, Request>(request: Request) throws -> String where Request: BSANSoapRequest<Params, Handler, Response, Parser> {

        let body = request.body
        var xmlToParse = ""

        if let filepath = Bundle.main.path(forResource: request.serviceName, ofType: "xml") {
            do {
                xmlToParse = try String(contentsOfFile: filepath)
            } catch {
                return ""
            }
        } else {
            return ""
        }

        let answerNumber = getAnswerNumber(request: request, body: body)

        if let document = try? XMLDocument(string: xmlToParse) {
            if let response = document.root?.children[answerNumber] {
                return response.children[0].rawXML
            }
        }
        return ""
    }

    func getAnswerNumber<Response, Params, Handler, Parser, Request>(request: Request, body: String) -> Int where Request: BSANSoapRequest<Params, Handler, Response, Parser> {

        var answerNumber = 0

        switch request.serviceName {
        case GlobalPositionRequest.SERVICE_NAME:
            answerNumber = 1
        case GlobalPositionRequest.SERVICE_NAME_PB:
            answerNumber = 2
        case GetSociusDetailAccountsAllRequest.SERVICE_NAME:
            answerNumber = 7
        default:
            break
        }
        BSANLogger.i(logTag, "getAnswerNumber result \(answerNumber)")
        return answerNumber
    }

}
