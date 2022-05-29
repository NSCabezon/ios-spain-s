import Foundation

public enum OTPPushDeviceResponseDTO: Codable {
    
    case device(OTPPushDeviceDTO)
    case error(String)
    
    enum OTPPushDeviceResponseDTOError: Error {
        case decoding(String)
    }
    
    private enum CodingKeys: String, CodingKey {
        case device
        case error
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(OTPPushDeviceDTO.self, forKey: .device) {
            self = .device(value)
            return
        }
        if let value = try? values.decode(String.self, forKey: .error) {
            self = .error(value)
            return
        }
        throw OTPPushDeviceResponseDTOError.decoding("\(dump(values))")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .device(let device):
            try container.encode(device, forKey: .device)
        case .error(let value):
            try container.encode(value, forKey: .error)
        }
    }
}

public struct OTPPushDeviceDTO: Codable  {
    public let registerDate: Date
    public let deviceAlias: String?
    public let deviceLanguage: String
    public let deviceCode: String
    public let deviceModel: String
    public let deviceBrand: String
    public let appVersion: String
    public let sdkVersion: String
    public let soVersion: String
    public let platform: String
    public let modUser: String
    public let modDate: Date
    
    public init(registerDate: Date, deviceAlias: String?, deviceLanguage: String, deviceCode: String, deviceModel: String, deviceBrand: String, appVersion: String, sdkVersion: String, soVersion: String, platform: String, modUser: String, modDate: Date) {
        self.registerDate = registerDate
        self.deviceAlias = deviceAlias
        self.deviceLanguage = deviceLanguage
        self.deviceCode = deviceCode
        self.deviceModel = deviceModel
        self.deviceBrand = deviceBrand
        self.appVersion = appVersion
        self.sdkVersion = sdkVersion
        self.soVersion = soVersion
        self.platform = platform
        self.modUser = modUser
        self.modDate = modDate
    }
}
