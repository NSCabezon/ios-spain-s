import CoreFoundationLib

public final class RemoveOtpPushNotificationUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepositoy: AppRepositoryProtocol = self.dependenciesResolver.resolve()
        guard
            let persistedUser = try? appRepositoy.getPersistedUser().getResponseData(),
            let userId = persistedUser.userId
            else { return .error(StringErrorOutput(nil)) }
        let userPref = appRepositoy.getUserPreferences(userId: userId)
        userPref.otpPushNotification = nil
        appRepositoy.setUserPreferences(userPref: userPref)
        return .ok()
    }
}
