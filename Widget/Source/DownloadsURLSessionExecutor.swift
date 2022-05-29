import Foundation
import CoreFoundationLib
import RetailLegacy
import ESCommons

struct HTTPHeader {
    let key: AnyHashable
    let value: Any
}

extension HTTPMethodType {
    var urlSessionMethodType: String {
        return rawValue
    }
}

protocol URLSessionExecutorSource {
    var urlRequest: URLRequest? { get }
}

extension NativeRequestComponents: URLSessionExecutorSource {
    var urlRequest: URLRequest? {
        return nativeRequest
    }
}

extension OrdinaryRequestComponents: URLSessionExecutorSource {
    var urlRequest: URLRequest? {
        let final: URL?
        if case .get = method, !params.isEmpty {
            var components = URLComponents(string: url)
            components?.queryItems = params.map({ (key, value) -> URLQueryItem in
                return URLQueryItem(name: key, value: value)
            })
            final = components?.url
        } else {
            final = URL(string: url)
        }
        
        guard let validUrl = final else {
            return nil
        }
        
        var urlRequest = URLRequest(url: validUrl)
        urlRequest.httpMethod = method.urlSessionMethodType
        
        if case .post = method {
            let body = params.map({ "\($0)=\($1)" }).joined(separator: "&")
            urlRequest.httpBody = body.data(using: .utf8)
        }
        
        let cookies = Array(self.cookies.compactMapValues({ HTTPCookie(properties: $0) }).values)
        urlRequest.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        
        return urlRequest
    }
}

enum URLSessionExecutorError: Error {
    case notValidRequest
}

class NetworkURLSessionExecutor: NSObject {
    struct Constants {
        static let headerCookieName = "Cookie"
        static let headerEncodingName = "Accept-Encoding"
        static let headerEncodingValue = ""
    }
    private func evaluateError(error: Error?, response: URLResponse?) -> NetworkError {
        return .other
    }
}

extension NetworkURLSessionExecutor: NetworkServiceExecutor {
    func executeCall<Response, Handler, Request>(request: Request) throws -> Data where Request: NetworkRequest<Handler, Response> {
        guard let urlRequest = (request.components as? URLSessionExecutorSource)?.urlRequest  else {
            throw URLSessionExecutorError.notValidRequest
        }
        let response = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil).synchronousDataTask(with: urlRequest)
        guard let data = response.data else {
            throw evaluateError(error: response.error, response: response.response)
        }
        
        return data
    }
}

extension NetworkURLSessionExecutor: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if Compilation().isTrustInvalidCertificateEnabled && challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.useCredential, challenge.protectionSpace.serverTrust.map(URLCredential.init))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

private extension URLSession {
    
    struct Response {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    func synchronousDataTask(with urlRequest: URLRequest) -> URLSession.Response {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        let dataTask = self.dataTask(with: urlRequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return Response(data: data, response: response, error: error)
    }
}
