import Foundation

public class NetworkServiceImpl {
    let callExecutor: NetworkServiceExecutor
    
    public init(callExecutor: NetworkServiceExecutor) {
        self.callExecutor = callExecutor
    }
}

extension NetworkServiceImpl: NetworkService {
    public func executeCall<Handler, Response>(request: NetworkRequest<Handler, Response>) throws -> Response where Response: NetworkResponse {
        do {
            let rawResponse = try callExecutor.executeCall(request: request)
            return request.get(response: rawResponse)
        } catch let exception as NetworkError {
            throw exception
        }
    }
}
