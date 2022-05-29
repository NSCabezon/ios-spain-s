public protocol AuthDataSource {
    func getApiTokenCredential(absoluteUrl: String, clientId: String, clientSecret: String, scope: String, grantType: String, token: String) throws -> TokenOAuthDTO?
}
