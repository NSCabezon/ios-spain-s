
public final class SaveOtpNotificationUseCase: UseCase<SaveOtpNotificationUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: SaveOtpNotificationUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepositoy: AppRepositoryProtocol = self.dependenciesResolver.resolve()
        guard
            let persistedUser = try? appRepositoy.getPersistedUser().getResponseData(),
            let userId = persistedUser.userId
            else { return .error(StringErrorOutput(nil)) }
        let userPref = appRepositoy.getUserPreferences(userId: userId)
        userPref.otpPushNotification = TwinpushPersistedNotification(code: requestValues.code, sentDate: requestValues.sentDate)
        appRepositoy.setUserPreferences(userPref: userPref)
        return .ok()
    }
}

public struct SaveOtpNotificationUseCaseInput {
    public let code: String
    public let sentDate: Date
    
    public init(code: String, sentDate: Date) {
        self.code = code
        self.sentDate = sentDate
    }
}
