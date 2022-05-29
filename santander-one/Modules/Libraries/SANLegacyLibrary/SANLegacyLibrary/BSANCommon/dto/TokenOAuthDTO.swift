import SwiftyJSON

public struct TokenOAuthDTO: Codable, RestParser {
    public let tokenType: String?
    public let accessToken: String?
    public let expiresIn: String?
    public let scope: String?
    
    public init(json: JSON) {        
        self.tokenType = json["token_type"].string
        self.accessToken = json["access_token"].string
        self.expiresIn = json["expires_in"].string
        self.scope = json["scope"].string
    }
}
