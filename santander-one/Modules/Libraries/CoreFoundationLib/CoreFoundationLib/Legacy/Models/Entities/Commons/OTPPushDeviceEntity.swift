import Foundation
import SANLegacyLibrary

public struct OTPPushDeviceEntity {
    private let dto: OTPPushDeviceDTO
    public var deviceDTO: OTPPushDeviceDTO {
        return dto
    }
    public var model: String {
        return deviceDTO.deviceModel
    }
    public var alias: String? {
        return deviceDTO.deviceAlias
    }
    public var registrationDate: Date {
        return deviceDTO.registerDate
    }
    public var deviceCode: String {
        return deviceDTO.deviceCode
    }
    
    public init(deviceDTO: OTPPushDeviceDTO) {
        self.dto = deviceDTO
    }
}
