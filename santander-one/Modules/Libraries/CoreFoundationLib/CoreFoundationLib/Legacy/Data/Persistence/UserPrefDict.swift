public class UserPrefDict: Codable {
    private var userPrefs = [String: UserPrefDTO]()

    public func getUserPrefDTO(userId: String) -> UserPrefDTO {
        if let userPrefDTO = userPrefs[userId] {
            return userPrefDTO
        }
        let userPref = UserPrefDTO(userId: userId)
        userPrefs[userId] = userPref
        return userPref
    }

    public func setUserPrefDTO(userPrefDTO: UserPrefDTO) {
        userPrefs[userPrefDTO.userId] = userPrefDTO
    }
}
