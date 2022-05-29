public struct TouchIdLoginDTO: Codable {
    public var deviceMagicPhrase: String?
    public var deviceId: String?
    public var credentialsDTO: CredentialsDTO?
    
    public init() {}
}
