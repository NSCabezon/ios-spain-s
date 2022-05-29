import CoreFoundationLib

public final class SANSaveOtpNotificationUseCase: UseCase<SANSaveOtpNotificationUseCaseInput, Void, StringErrorOutput> {
    private let daoSharedPersistedUserProtocol: DAOSharedPersistedUserProtocol
    private let daoUserPref: DAOSharedUserPrefEntityProtocol
    
    public init(daoSharedPersistedUserProtocol: DAOSharedPersistedUserProtocol, daoUserPref: DAOSharedUserPrefEntityProtocol) {
        self.daoSharedPersistedUserProtocol = daoSharedPersistedUserProtocol
        self.daoUserPref = daoUserPref
    }
    
    public override func executeUseCase(requestValues: SANSaveOtpNotificationUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard
            let persistedUser = daoSharedPersistedUserProtocol.get(),
            let userId = persistedUser.userId
            else { return .error(StringErrorOutput(nil)) }
        let userPrefDict = daoUserPref.get()
        var userPref = userPrefDict.getSharedUserPrefEntity(userId: userId)
        let notification = TwinpushPersistedNotification(code: requestValues.code, sentDate: requestValues.sentDate)
        userPref.otpPushNotification = notification
        userPrefDict.setSharedUserPrefEntity(userPrefDTO: userPref)
        _ = daoUserPref.set(userPrefs: userPrefDict)
        return .ok()
    }
}

public struct SANSaveOtpNotificationUseCaseInput {
    let code: String
    let sentDate: Date
    
    public init(code: String, sentDate: Date) {
        self.code = code
        self.sentDate = sentDate
    }
}
