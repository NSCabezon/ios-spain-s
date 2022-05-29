import CoreDomain
import Foundation

public struct SantanderKeyUpdateTokenPushInput: Encodable {
    public let deviceId: String?
    public let udid: String?
    public let tokenPush: String?
    public let deviceCode: String?
    public let deviceModel: String?
    public let deviceFabric: String?
    public let appVersion: String?
    public let sdkVersion: String?
    public let soVersion: String?
    public let devicePlatform: String?
    
    enum CodingKeys: String, CodingKey {
        case deviceId
        case udid
        case tokenPush
        case deviceCode
        case deviceModel
        case deviceFabric
        case appVersion
        case sdkVersion
        case soVersion
        case devicePlatform
    }
    
    public init(deviceId: String,
                udid: String,
                tokenPush: String,
                deviceCode: String,
                deviceModel: String,
                deviceFabric: String,
                appVersion: String,
                sdkVersion: String,
                soVersion: String,
                devicePlatform: String) {
        self.deviceId = deviceId
        self.udid = udid
        self.tokenPush = tokenPush
        self.deviceCode = deviceCode
        self.deviceModel = deviceModel
        self.deviceFabric = deviceFabric
        self.appVersion = appVersion
        self.sdkVersion = sdkVersion
        self.soVersion = soVersion
        self.devicePlatform = devicePlatform
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(udid, forKey: .udid)
        try container.encode(tokenPush, forKey: .tokenPush)
        try container.encode(deviceCode, forKey: .deviceCode)
        try container.encode(deviceModel, forKey: .deviceModel)
        try container.encode(deviceFabric, forKey: .deviceFabric)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(sdkVersion, forKey: .sdkVersion)
        try container.encode(soVersion, forKey: .soVersion)
        try container.encode(devicePlatform, forKey: .devicePlatform)
    }
}
