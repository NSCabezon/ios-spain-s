import Foundation
import CoreFoundationLib

public protocol NetworkResponse {
    associatedtype T
    var data: T { get }
    
    init(response: Data)
}

public protocol RequestComponents {
    var identifier: String { get }
}

public struct OrdinaryRequestComponents: RequestComponents {
    public let url: String
    public let params: [String: String]
    public let method: HTTPMethodType
    public let fields: [String: String]?
    public let cookies: [String: [HTTPCookiePropertyKey: Any]]
    public var headers: [String: String]? = [:]

    public var identifier: String {
        return url
    }
}

public struct NativeRequestComponents: RequestComponents {
    public let nativeRequest: URLRequest
    
    public var identifier: String {
        return nativeRequest.url?.absoluteString ?? ""
    }
}

public class NetworkRequest<Handler, Response: NetworkResponse> {
    public let components: RequestComponents
    
    init(components: RequestComponents) {
        self.components = components
    }
    
    func get(response: Data) -> Response {
        return Response(response: response)
    }
}
