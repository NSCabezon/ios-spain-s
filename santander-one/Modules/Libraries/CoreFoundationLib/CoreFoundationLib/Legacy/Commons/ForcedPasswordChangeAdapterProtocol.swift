public protocol ForcedPasswordChangeAdapterProtocol {
    var isForcedPasswordChange: Bool { get }
}

public struct SetNeedUpdatePasswordConfiguration {
    public let forceToUpdatePassword: Bool

    public init(forceToUpdatePassword: Bool) {
        self.forceToUpdatePassword = forceToUpdatePassword
    }
}
