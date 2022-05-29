import SANLegacyLibrary

enum SendViaScaDO {
    case push
    case sms
    
    init(dto: SendViaSca) {
        switch dto {
        case .push: self = .push
        case .sms: self = .sms
        }
    }
}

public struct ValidateSca {
    public init(dto: ValidateScaDTO) {
        self.dto = dto
    }
    
    let dto: ValidateScaDTO
    
    var deviceTelephone: String? {
        dto.deviceTelephone
    }
    
    var telephone: String? {
        dto.telephone
    }
    
    var via: SendViaScaDO? {
        guard let via = dto.via else { return nil }
        return SendViaScaDO(dto: via)
    }
}
