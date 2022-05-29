public class UserPrefDictEntity: Codable {
    public var userPrefs: [String: UserPrefDTOEntity] = [:]
    
    public init() {
        
    }
    
    public func isUserPrefDTO(userId: String) -> Bool {
        return userPrefs[userId] != nil
    }
    
    public func getIfExistsUserPrefDTO(userId: String) -> UserPrefDTOEntity? {
        guard let userPrefDTO = userPrefs[userId] else {
            return nil
        }
        return userPrefDTO
    }

    public func getUserPrefDTO(userId: String) -> UserPrefDTOEntity {
        if let userPrefDTO = userPrefs[userId] {
            return userPrefDTO
        }
        let entity = UserPrefDTOEntity(userId: userId)
        userPrefs[userId] = entity
        return entity
    }

    public func setUserPrefDTO(userPrefDTO: UserPrefDTOEntity) {
        userPrefs[userPrefDTO.userId] = userPrefDTO
    }
}
