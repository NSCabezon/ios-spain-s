import Foundation

public protocol NetworkServiceExecutor {
    func executeCall<Response, Handler, Request>(request: Request) throws -> Data where Request: NetworkRequest<Handler, Response>
}
