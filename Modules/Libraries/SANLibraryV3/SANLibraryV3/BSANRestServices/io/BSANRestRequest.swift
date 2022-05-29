import Foundation
public class BSANRestRequest<Params, Handler, Response, Parser> where Parser: BSANParser<Response, Handler> {
    
    public var serviceName: String { fatalError() }
    
    public var serviceUrl: String {
        return baseServiceUrl
    }
    public var body: String {
        return createMessage()
    }
    
    var nameSpace: String {fatalError()}
    var message: String {fatalError()}
    
    var params: Params
    
    var LOG_TAG: String {
        return String(describing: type(of: self))
    }
    
    var urlBase: String
    
    public init(urlBase: String,_ params: Params) {
        self.urlBase = urlBase
        self.params = params
    }
    
    var baseServiceUrl: String {
        return urlBase
    }
    
    var parser: Parser {
        return Parser.init()
    }
    
    func getResponse(response: String) -> Response {
        return Response.init(response: response)
    }
    
    func parse(response: String) throws -> Response {
        
        BSANLogger.i(LOG_TAG, "parse")
        BSANLogger.d(LOG_TAG, "Response:\n\(response)")
        
        if !response.isEmpty {
            return try parser.parse(bsanResponse: getResponse(response: response))
        } else {
            throw BSANServiceException("Empty Response String!")
        }
    }
    
    func createMessage() -> String {
        BSANLogger.d(LOG_TAG, "Request:\n\(message)")
        return message
    }
    
    
}
