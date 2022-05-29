import SwiftyJSON

public class AuthDataSourceImpl : AuthDataSource{
    
    public static let AUTH_GET_API_TOKEN_SERVICE_NAME = "auth_get_api_token"
    private let sanRestServices : SanRestServices
    
    public init(sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
    }
    
    public func getApiTokenCredential(absoluteUrl: String, clientId: String, clientSecret: String, scope: String, grantType: String, token: String) throws -> TokenOAuthDTO? {
        
        let params = ["client_id" : clientId,
                      "client_secret" : clientSecret,
                      "scope" : scope,
                      "grant_type" : grantType,
                      "token" : token]
        
        if let response: Any = try sanRestServices.executeRestCall(request: RestRequest(serviceName: AuthDataSourceImpl.AUTH_GET_API_TOKEN_SERVICE_NAME,
                                                                                        serviceUrl: absoluteUrl,
                                                                                        params: params,
                                                                                        contentType: ContentType.urlEncoded)){
            if let response = response as? String{
                return TokenOAuthDTO(json: JSON.init(parseJSON: response))
            }
        }
        
        return nil
    }
}
