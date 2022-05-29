import SANLegacyLibrary
import CoreDomain

struct UserDO {
    let dto: UserDataDTO?
    
    var userId: String? {
        guard let userDataDTO = dto, let userType = userDataDTO.clientPersonType, let userCode = userDataDTO.clientPersonCode else {
            return nil
        }
        return userType + userCode
    }
    
    var userCodeType: String? {
        guard let userDataDTO = dto, let userType = userDataDTO.clientPersonType, let userCode = userDataDTO.clientPersonCode else {
            return nil
        }
        return userCode + userType
    }
    
    var userKey: String? {
        guard let userDataDTO = dto, let userType = userDataDTO.clientPersonType, let userCode = userDataDTO.clientPersonCode else {
            return nil
        }
        return userType + "," + userCode
    }
}

extension UserDO: UserRepresentable {
    var userDataRepresentable: UserDataRepresentable? {
        return dto
    }
}
