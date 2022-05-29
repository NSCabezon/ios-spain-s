import SANLegacyLibrary

public final class PersistedUserDTO: Codable, CustomStringConvertible {

    public static func createPersistedUser(loginType: UserLoginType, login: String, environmentName: String) -> PersistedUserDTO {
        return PersistedUserDTO(loginType: loginType, login: login, environmentName: environmentName)
    }
    
    // swiftlint:disable function_parameter_count
    public static func createPersistedUser(touchTokenCiphered: String?, loginType: UserLoginType, login: String, environmentName: String, channelFrame: String?, isPb: Bool, name: String?, bdpCode: String?, comCode: String?, isSmart: Bool, userId: String?, biometryData: Data?) -> PersistedUserDTO {
        return PersistedUserDTO(touchTokenCiphered: touchTokenCiphered, loginType: loginType, login: login, environmentName: environmentName, channelFrame: channelFrame, isPb: isPb, name: name, bdpCode: bdpCode, comCode: comCode, isSmart: isSmart, userId: userId, biometryData: biometryData)
    }
    // swiftlint:enable function_parameter_count
   
    public var loginType: UserLoginType
    public var login: String
    public var environmentName: String
    public var touchTokenCiphered: String?
    public var channelFrame: String?
    public var isPb: Bool = false
    public var name: String?
    public var bdpCode: String?
    public var comCode: String?
    public var isSmart: Bool = false
    public var userId: String?
    public var biometryData: Data?

    private init(touchTokenCiphered: String?, loginType: UserLoginType, login: String, environmentName: String, channelFrame: String?, isPb: Bool, name: String?, bdpCode: String?, comCode: String?, isSmart: Bool, userId: String?, biometryData: Data?) {
        self.touchTokenCiphered = touchTokenCiphered
        self.loginType = loginType
        self.login = login
        self.environmentName = environmentName
        self.channelFrame = channelFrame
        self.isPb = isPb
        self.name = name
        self.bdpCode = bdpCode
        self.comCode = comCode
        self.isSmart = isSmart
        self.userId = userId
        self.biometryData = biometryData
    }

    private init(loginType: UserLoginType, login: String, environmentName: String) {
        self.loginType = loginType
        self.login = login
        self.environmentName = environmentName
    }
    
    public var description: String {
        return "PersistedUserDTO {" +
            " touchTokenCiphered=\(touchTokenCiphered ?? "")" +
            ", loginType = \(loginType)" +
            ", login= \(login)" +
            ", environmentName= \(environmentName)" +
            ", channelFrame= \(channelFrame ?? "")" +
            ", persistedUserIsPb= \(isPb)" +
            ", name= \(name ?? "")" +
            ", bdpCode= \(bdpCode ?? "")" +
            ", comCode= \(comCode ?? "")" +
            ", isSmart= \(isSmart)" +
            ", userId= \(userId ?? "")}"
    }
    
    public var sharedPersistedUser: SharedPersistedUserDTO {
        return SharedPersistedUserDTO(loginType: loginType.rawValue,
                                      login: login,
                                      environmentName: environmentName,
                                      channelFrame: channelFrame,
                                      isPb: isPb,
                                      name: name,
                                      bdpCode: bdpCode,
                                      comCode: comCode,
                                      isSmart: isSmart,
                                      userId: userId,
                                      biometryData: biometryData)
    }
}
