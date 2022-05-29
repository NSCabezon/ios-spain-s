import CoreFoundationLib

final class SaveNotificationManager {
    private let dependencies: NotificationServiceDependenciesProtocol
    
    init(dependencies: NotificationServiceDependenciesProtocol) {
        self.dependencies = dependencies
    }
    
    func saveNotification(info: PushInfo) {
        guard let info = info as? TwinPushInfo,
              let code = info["otp"] as? String,
              !code.isEmpty
        else { return }
        if case .otp = info.executableType {
            saveOtp(otp: code, date: info.date)
        }
    }
    
    func saveOtp(otp: String, date: Date) {
        Scenario(
            useCase: dependencies.otpUseCase,
            input: SANSaveOtpNotificationUseCaseInput(code: otp, sentDate: date.toLocalTime())
        )
        .execute(on: DispatchQueue.main)
    }
    
    func saveEcommerce(code: String, date: Date) {
        Scenario(
            useCase: dependencies.ecommerceUseCase,
            input: SaveEcommerceNotificationUseCaseInput(code: code, sentDate: date.toLocalTime())
        )
        .execute(on: DispatchQueue.main)
    }
}
