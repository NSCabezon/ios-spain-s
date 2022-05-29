import Foundation

public protocol SoapServiceExecutor {
    func executeCall  <Response, Params, Handler ,  Parser,  Request> (request: Request ) throws -> String where Request:  BSANSoapRequest<Params, Handler, Response, Parser>
}
