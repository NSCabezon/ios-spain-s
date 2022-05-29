import Foundation

public enum RequesType {
    case post
    case get
}

/// Create an object wich represent the request body.
public struct Body {
    let data: Data?
    let contentType: ContentType
    /// initialize a Body value using an object wich conform to Codable and the contentType is set to json
    /// - Parameter bodyParam: the object to be encoded in the http body
    public init<BodyCodableParam: Encodable>(bodyParam: BodyCodableParam) {
        self.contentType = .json
        self.data = RestRequest.bodyData(for: bodyParam)
    }
    
    /// create a body value using key value parameter
    /// - Parameters:
    ///   - bodyParam: the key value params to be encoded in the body
    ///   - contentType: by default is urlEncoded or json but queryString make no sense and will be discarded on future api.
    public init(bodyParam: [String: Any], removesEscapeCharacters: Bool = false, contentType: ContentType = .urlEncoded) {
        self.data = RestRequest.getHttpBody(params: bodyParam, removesEscapeCharacters: removesEscapeCharacters, contentType: contentType)
        self.contentType = contentType
    }
}

public class RestRequest{
    public let serviceName: String
    public let serviceUrl: String
    public let queryParams: String?
    public let body: Data?
    public let contentType: ContentType
    let requestType: RequesType
    let headers: [String:String]
    let responseEncoding: String.Encoding?
    @available(*, deprecated, message: "This constructor will be available temporally")
    init(serviceName: String, serviceUrl: String, params: [String: Any], removesEscapeCharacters: Bool = false, contentType: ContentType, requestType: RequesType = .get, headers: [String: String] = [:], responseEncoding: String.Encoding? = nil) {
        self.serviceName = serviceName
        self.serviceUrl = serviceUrl
        self.contentType = contentType
        self.requestType = requestType
        self.headers = headers
        self.responseEncoding = responseEncoding
        switch contentType {
        case .queryString:
            self.body = nil
            self.queryParams = RestRequest.getQueryString(params: params)
        case .json, .urlEncoded:
            self.queryParams = nil
            self.body = RestRequest.getHttpBody(params: params, removesEscapeCharacters: removesEscapeCharacters, contentType: contentType)
        }
    }
    
    init(serviceName: String, serviceUrl: String, body: Body?, queryParams: [String: Any]?, requestType: RequesType = .get, headers: [String: String] = [:], responseEncoding: String.Encoding? = nil) {
        self.serviceName = serviceName
        self.serviceUrl = serviceUrl
        self.headers = headers
        self.responseEncoding = responseEncoding
        self.body = body?.data
        self.contentType = body?.contentType ?? .json
        self.requestType = requestType
        self.queryParams = queryParams.flatMap(RestRequest.getQueryString)
    }
}

extension RestRequest {
    static func getHttpBody(params: [String : Any], removesEscapeCharacters: Bool, contentType: ContentType) -> Data? {
        switch contentType {
        case .json:
            guard removesEscapeCharacters else {
                return getData(params)
            }
            return getDataRemovingSpecialCharacters(params)
        case .urlEncoded:
            let output = params.asQueryString()
            return output.data(using: String.Encoding.utf8, allowLossyConversion: false)
        case .queryString:
            return nil
        }
    }
    
    private static func getData(_ params: [String : Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
    }
    
    private static func getDataRemovingSpecialCharacters(_ params: [String : Any]) -> Data? {
        guard let data = try? JSONSerialization.data(withJSONObject: params, options: []),
              let filteredString = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/"),
              let newData = filteredString.data(using: .utf8)
        else { return nil }
        return newData
    }
    
    static func getQueryString(params: [String : Any]) -> String? {
        return params.asQueryString()
    }
    
    static func bodyData<Object: Encodable>(for object: Object) -> Data? {
        let encoder = JSONEncoder()
        if let dateParseable = Object.self as? DateParseable.Type {
            encoder.dateEncodingStrategy = .custom(dateParseable.encoding)
        }
        return try? encoder.encode(object)
    }
}
