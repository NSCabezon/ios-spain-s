import CoreDomain
import Foundation

public struct SantanderKeyRegisterConfirmationInput: Encodable {
    public let otpReference: String?
    public let otpValue: String?
    public let sanKeyId: String?
    public let udid: String?
    public let publicKey: String?
    public let tokenPush: String?
    public let deviceAlias: String?
    public let deviceLanguage: String?
    public let deviceCode: String?
    public let deviceModel: String?
    public let deviceFabric: String?
    public let appVersion: String?
    public let sdkVersion: String?
    public let soVersion: String?
    public let devicePlatform: String?
    public let modUser: String?
    public let trusteerInfo: SantanderKeyTrusteerInfo?
    public let geoDevice: SantanderKeyGeolocation?
    
    enum CodingKeys: String, CodingKey {
        case otpReference
        case otpValue
        case sanKeyId
        case udid
        case publicKey
        case tokenPush
        case deviceAlias
        case deviceLanguage
        case deviceCode
        case deviceModel
        case deviceFabric
        case appVersion
        case sdkVersion
        case soVersion
        case devicePlatform
        case modUser
        case trusteerInfo
        case geoDevice
    }
    
    public init(otpReference: String,
                otpValue: String,
                sanKeyId: String,
                udid: String,
                publicKey: String,
                tokenPush: String,
                deviceAlias: String,
                deviceLanguage: String,
                deviceCode: String,
                deviceModel: String,
                deviceFabric: String,
                appVersion: String,
                sdkVersion: String,
                soVersion: String,
                devicePlatform: String,
                modUser: String,
                trusteerInfo: SantanderKeyTrusteerInfo?,
                geoDevice: SantanderKeyGeolocation?) {
        self.otpReference = otpReference
        self.otpValue = otpValue
        self.sanKeyId = sanKeyId
        self.udid = udid
        self.publicKey = publicKey
        self.tokenPush = tokenPush
        self.deviceAlias = deviceAlias
        self.deviceLanguage = deviceLanguage
        self.deviceCode = deviceCode
        self.deviceModel = deviceModel
        self.deviceFabric = deviceFabric
        self.appVersion = appVersion
        self.sdkVersion = sdkVersion
        self.soVersion = soVersion
        self.devicePlatform = devicePlatform
        self.modUser = modUser
        self.trusteerInfo = trusteerInfo
        self.geoDevice = geoDevice
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(otpReference, forKey: .otpReference)
        try container.encode(otpValue, forKey: .otpValue)
        try container.encode(sanKeyId, forKey: .sanKeyId)
        try container.encode(udid, forKey: .udid)
        try container.encode(publicKey, forKey: .publicKey)
        try container.encode(tokenPush, forKey: .tokenPush)
        try container.encode(deviceAlias, forKey: .deviceAlias)
        try container.encode(deviceLanguage, forKey: .deviceLanguage)
        try container.encode(deviceCode, forKey: .deviceCode)
        try container.encode(deviceModel, forKey: .deviceModel)
        try container.encode(deviceFabric, forKey: .deviceFabric)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(sdkVersion, forKey: .sdkVersion)
        try container.encode(soVersion, forKey: .soVersion)
        try container.encode(devicePlatform, forKey: .devicePlatform)
        try container.encode(modUser, forKey: .modUser)
        try container.encode(trusteerInfo, forKey: .trusteerInfo)
        try container.encode(geoDevice, forKey: .geoDevice)
    }
}

public struct SantanderKeyTrusteerInfo: Codable {
    public let userAgent: String?
    public let customerSessionId: String?
    public let url: String?
    
    enum CodingKeys: String, CodingKey {
        case userAgent
        case customerSessionId
        case url
    }
    
    public init(userAgent: String,customerSessionId: String, url: String) {
        self.userAgent = userAgent
        self.customerSessionId = customerSessionId
        self.url = url
    }
}

public struct SantanderKeyGeolocation: Codable {
    public let longitude: String?
    public let latitude: String?
    
    enum CodingKeys: String, CodingKey {
        case longitude
        case latitude
    }
    
    public init(longitude: String,
                latitude: String) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
