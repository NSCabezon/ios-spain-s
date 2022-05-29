import Foundation

public protocol SanSoapServices {
    
    func executeCall <Params, Handler, Response , Parser> (_ request: BSANSoapRequest<Params, Handler, Response, Parser>) throws -> Response
}
