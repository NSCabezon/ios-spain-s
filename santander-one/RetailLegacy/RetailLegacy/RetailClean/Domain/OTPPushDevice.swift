import Foundation
import SANLegacyLibrary
import CoreFoundationLib

public struct OTPPushDevice {
    private(set) var deviceDTO: OTPPushDeviceDTO
    
    init(deviceDTO: OTPPushDeviceDTO) {
        self.deviceDTO = deviceDTO
    }
    
    init(deviceEntity: OTPPushDeviceEntity) {
        self.deviceDTO = deviceEntity.deviceDTO
    }
    
    var model: String {
        return deviceDTO.deviceModel
    }
    
    var alias: String? {
        return deviceDTO.deviceAlias
    }
    
    var registrationDate: Date {
        return deviceDTO.registerDate
    }
    
    var deviceCode: String {
        return deviceDTO.deviceCode
    }
    
    func createEntity() -> OTPPushDeviceEntity {
        return OTPPushDeviceEntity(deviceDTO: deviceDTO)
    }
}
