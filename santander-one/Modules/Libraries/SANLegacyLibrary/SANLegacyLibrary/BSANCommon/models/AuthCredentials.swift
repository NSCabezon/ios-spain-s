import Foundation

public class AuthCredentials: Codable {

    public var soapTokenCredential: String
    public var apiTokenCredential: String?
    public var apiTokenType: String?

    public init(soapTokenCredential: String, apiTokenCredential: String? = nil, apiTokenType: String? = nil) {
        self.soapTokenCredential = soapTokenCredential
        self.apiTokenCredential = apiTokenCredential
        self.apiTokenType = apiTokenType
    }
}

extension AuthCredentials: AuthCredentialsProvider {
    public var timelineToken: String? {
        return soapTokenCredential
    }
}

public protocol AuthCredentialsProvider {
    var timelineToken: String? { get }
}
