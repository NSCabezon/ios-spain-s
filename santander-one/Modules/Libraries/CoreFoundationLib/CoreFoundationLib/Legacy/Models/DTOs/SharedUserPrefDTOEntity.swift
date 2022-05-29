public struct SharedUserPrefDTOEntity: Codable {
    public var userId: String
    public var otpPushNotification: TwinpushPersistedNotification?
    public var ecommercePushNotification: TwinpushPersistedNotification?
    
    public init(userPref: UserPrefDTOEntity) {
        self.userId = userPref.userId
        self.otpPushNotification = userPref.otpPushNotification
        self.ecommercePushNotification = userPref.ecommercePushNotification
    }
    
    public init(userId: String) {
        self.userId = userId
    }
}
