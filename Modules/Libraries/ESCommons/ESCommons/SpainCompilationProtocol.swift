import CoreFoundationLib
import SANLibraryV3

public protocol SpainCompilationProtocol: CompilationProtocol {
    var quickbalance: String { get }
    var salesForceAppId: String { get }
    var salesForceAccessToken: String { get }
    var salesForceEndPoint: String { get }
    var salesForceMid: String { get }
    var emmaApiKey: String { get }
    var keychainSantanderKey: CompilationSantanderKeyProtocol { get }
}

public protocol CompilationSantanderKeyProtocol {
    var deviceId: String { get }
    var RSAPrivateKey: String { get }
    var RSAPublicKey: String { get }
    var sankeyId: String {get }
}

public struct SPDomainConstant {
    public static let deviceIdIdentifier = "deviceId"
    public static let RSAPrivateKey = "RSAPrivatecKey"
    public static let RSAPublicKey = "RSAPublicKey"
    public static let santanderKeyIdentifier = "sankeyId"
}
