import CoreFoundationLib

public final class GetEcommercePushNotificationUseCase: UseCase<Void, GetEcommercePushNotificationUseCaseOkOutput, StringErrorOutput> {
    private let secondsInAMinute: Int = 60
    private let appRepository: AppRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.appRepository = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetEcommercePushNotificationUseCaseOkOutput, StringErrorOutput> {
        guard
            let persistedUser = try? appRepository.getPersistedUser().getResponseData(),
            let userId = persistedUser.userId
            else { return .error(StringErrorOutput(nil)) }
        let userPref = appRepository.getUserPreferences(userId: userId)
        guard
            let notification = userPref.ecommercePushNotification
        else {
            let lastPurchaseInfo = EcommerceLastPurchaseInfo(code: "", remainingTime: nil)
            return .ok(GetEcommercePushNotificationUseCaseOkOutput(lastPurchaseInfo: lastPurchaseInfo))
        }
        let maxMinutes = TimeInterval(PushNotificationMaxTime.ecommerce * secondsInAMinute)
        let localDate = Date().toLocalTime()
        let remainingSeconds = localDate.timeIntervalSince(notification.sentDate)
        if remainingSeconds > maxMinutes {
            userPref.ecommercePushNotification = nil
            appRepository.setUserPreferences(userPref: userPref)
            let lastPurchaseInfo = EcommerceLastPurchaseInfo(code: notification.code, remainingTime: nil)
            return .ok(GetEcommercePushNotificationUseCaseOkOutput(lastPurchaseInfo: lastPurchaseInfo))
        } else {
            let remainingTime = max(0, min(maxMinutes - remainingSeconds, maxMinutes))
            let lastPurchaseInfo = EcommerceLastPurchaseInfo(code: notification.code, remainingTime: Int(remainingTime))
            return .ok(GetEcommercePushNotificationUseCaseOkOutput(lastPurchaseInfo: lastPurchaseInfo))
        }
    }
}

public struct GetEcommercePushNotificationUseCaseOkOutput {
    let lastPurchaseInfo: EcommerceLastPurchaseInfo
}
