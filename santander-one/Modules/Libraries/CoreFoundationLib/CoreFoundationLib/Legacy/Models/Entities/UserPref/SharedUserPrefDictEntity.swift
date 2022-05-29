public final class SharedUserPrefDictEntity: Codable {
    public var userPrefs: [String: SharedUserPrefDTOEntity] = [:]
    
    public init() {}
    
    public func isSharedUserPrefEntity(userId: String) -> Bool {
        return userPrefs[userId] != nil
    }

    public func getSharedUserPrefEntity(userId: String) -> SharedUserPrefDTOEntity {
        if let userPrefDTO = userPrefs[userId] {
            return userPrefDTO
        }
        let entity = SharedUserPrefDTOEntity(userId: userId)
        userPrefs[userId] = entity
        return entity
    }

    public func setSharedUserPrefEntity(userPrefDTO: SharedUserPrefDTOEntity) {
        userPrefs[userPrefDTO.userId] = userPrefDTO
    }
}
