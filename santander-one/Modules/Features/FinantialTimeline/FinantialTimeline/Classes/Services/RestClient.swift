//
//  RestClient.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 01/07/2019.
//

import Foundation

public enum RestClientHTTPMethod {
    case get
    case post
    case put
    case delete
    
    public func value() -> String {
        return self.toAlamofireHTTPMethod()
    }
    
    func toAlamofireHTTPMethod() -> String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        }
    }
}

public enum RestClientParams {
    
    case none
    case params(params: [String: Any], encoding: RestClientEncoding)
    
    func queryParams() -> [URLQueryItem]? {
        switch self {
        case .params(params: let params, encoding: let encoding):
            switch encoding {
            case .url(destination: let destination):
                switch destination {
                case .url:
                    return params.compactMap {
                        guard let stringParam = $0.value as? String else { return nil }
                        return URLQueryItem(name: $0.key, value: stringParam)
                    }
                default:
                     return nil
                }
            default:
                 return nil
            }
        default:
            return nil
        }
    }
    
    func body() -> Data? {
        switch self {
        case .params(params: let params, encoding: let encoding):
            switch encoding {
            case .url:
                return nil
            case .json:
                return try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
        default:
            return nil
        }
    }
}

public enum RestClientEncoding {
    public enum Destination {
        case body
        case url
    }

    case url(destination: Destination)
    case json
}

/// Implement this protocol in the entity that will handle the Rest API requests
public protocol RestClient {
    func request(
        host: String,
        path: String,
        method: RestClientHTTPMethod,
        headers: [String: String],
        params: RestClientParams,
        completion: @escaping (Swift.Result<Data, Error>) -> Void
    )
}

struct Request {
    
    let baseURLString: String
    let path: String
    let method: RestClientHTTPMethod
    let headers: [String: String]?
    let allowOffline: Bool
    let showDebugInfo: Bool
    
    init(baseURLString: String, path: String, method: RestClientHTTPMethod, headers: [String: String]? = nil, params: RestClientParams, showDebugInfo: Bool = false) {
        self.baseURLString = baseURLString
        self.path = path
        self.method = method
        self.headers = headers
        self.allowOffline = false
        self.showDebugInfo = showDebugInfo
    }
}

class IntelligentBankingRestClient: NSObject, RestClient {
    private var session: URLSession?
    private let operationQueue = OperationQueue()
    private let timeout = 1000
    
    override init() {
        super.init()
    }
    
    func request(host: String, path: String, method: RestClientHTTPMethod, headers: [String: String], params: RestClientParams, completion: @escaping (Swift.Result<Data, Error>) -> Void) {
        var urlString = host
        if urlString.last == "/" {
            urlString.removeLast()
        }
        urlString.append(path)
        guard let url = URL(string: urlString) else {
            return completion(.failure(TimeLineError.unknown))
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(timeout)
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let request = urlRequest(method: method.value(), url: url, headers: headers, params: params)
        let task = session?.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async(execute: {
                guard let unwrappedData = data else {
                    return completion(.failure(TimeLineError.unknown))
                }
                return completion(.success(unwrappedData))
            })
        })
        task?.resume()
    }
    
    // MARK: - Private methods
    
    private func dataTaskWillCacheResponse(_ session: URLSession, dataTask: URLSessionDataTask, response: CachedURLResponse) -> CachedURLResponse? {
        return nil
    }
    
    private func asyncRequest(method: String, url: URL, headers: [String: String], params: RestClientParams, completion: @escaping (Swift.Result<Data, Error>) -> Void) {
        var request = urlRequest(method: method, url: url, headers: headers, params: params)
        request.httpBody = params.body()
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let defaultSession = URLSession(configuration: .default)
        defaultSession.dataTask(with: request) { data, _, error in
            guard let data = data else {
                return completion(.failure(error ?? TimeLineError.unknown))
            }
            return completion(.success(data))
        }.resume()
    }
    
    private func urlRequest(method: String, url: URL, headers: [String: String], params: RestClientParams) -> URLRequest {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = params.queryParams()
        guard let urlWithParams = urlComponents?.url else { return URLRequest(url: url) }
        var request = URLRequest(url: urlWithParams)
        request.httpMethod = method
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        return request
    }
}

extension IntelligentBankingRestClient: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            disposition = URLSession.AuthChallengeDisposition.useCredential
            credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        } else if challenge.previousFailureCount > 0 {
            disposition = .cancelAuthenticationChallenge
        } else if credential != nil {
            disposition = .useCredential
        }
        return completionHandler(disposition, credential)
    }
}

extension Data {
    
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
