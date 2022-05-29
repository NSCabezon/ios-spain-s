public final class UserPrefDTOEntity: Codable {
    public var userId: String
    public var isUserPb: Bool = false
    public var isSmartUser: Bool = false
    public var pgUserPrefDTO: PGUserPrefDTOEntity = PGUserPrefDTOEntity()
    public var comingFeaturesVotedIds: [String] = []
    public var otpPushNotification: TwinpushPersistedNotification?
    public var ecommercePushNotification: TwinpushPersistedNotification?
    
    public init(userId: String) {
        self.userId = userId
    }
    
    public func asShared() -> SharedUserPrefDTOEntity {
        return SharedUserPrefDTOEntity(userPref: self)
    }
    
    public func updateWithSharedUserPref(_ sharedUserPref: SharedUserPrefDTOEntity) -> Bool {
        let isUpdatedOtp = updateOtp(with: sharedUserPref)
        let isUpdatedEcommerce = updateEcommerce(with: sharedUserPref)
        return isUpdatedOtp || isUpdatedEcommerce
    }
    
    private func updateOtp(with sharedUserPref: SharedUserPrefDTOEntity) -> Bool {
        let oldOtpPushNotification = self.otpPushNotification
        guard let localNotification = otpPushNotification else {
            otpPushNotification = sharedUserPref.otpPushNotification
            return oldOtpPushNotification != self.otpPushNotification
        }
        guard let sharedNotification = sharedUserPref.otpPushNotification,
              localNotification.sentDate < sharedNotification.sentDate
        else {
            return false
        }
        otpPushNotification = sharedNotification
        return oldOtpPushNotification != self.otpPushNotification
    }
    
    private func updateEcommerce(with sharedUserPref: SharedUserPrefDTOEntity) -> Bool {
        let oldEcommercePushNotification = self.ecommercePushNotification
        guard let localNotification = ecommercePushNotification else {
            ecommercePushNotification = sharedUserPref.ecommercePushNotification
            return oldEcommercePushNotification != self.ecommercePushNotification
        }
        guard let sharedNotification = sharedUserPref.ecommercePushNotification,
              localNotification.sentDate < sharedNotification.sentDate
        else {
            return false
        }
        ecommercePushNotification = sharedNotification
        return oldEcommercePushNotification != self.ecommercePushNotification
    }
}
