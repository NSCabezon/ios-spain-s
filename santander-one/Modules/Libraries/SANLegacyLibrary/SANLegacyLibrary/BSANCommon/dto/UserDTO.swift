
public struct UserDTO: Codable {
    public var isPB: Bool
    public let loginType: UserLoginType
    public let login: String
    
    public init(loginType: UserLoginType, login: String) {
        self.login = login
        self.loginType = loginType
        self.isPB = false
    }
}
