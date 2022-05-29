//
//  GetOtpPushNotificationUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/10/20.
//

import Foundation
import CoreFoundationLib

final class GetOtpPushNotificationUseCase: UseCase<Void, GetOtpPushNotificationUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetOtpPushNotificationUseCaseOkOutput, StringErrorOutput> {
        let appRepositoy: AppRepositoryProtocol = dependenciesResolver.resolve()
        guard
            let persistedUser = try? appRepositoy.getPersistedUser().getResponseData(),
            let userId = persistedUser.userId
            else { return .error(StringErrorOutput(nil)) }
        let userPref = appRepositoy.getUserPreferences(userId: userId)
        guard
            let notification = userPref.otpPushNotification
            else { return .ok(.noCode) }
        let actualDate = Date().toLocalTime()
        let remainingSeconds = actualDate.timeIntervalSince(notification.sentDate)
        if remainingSeconds > 5 * 60 {
            userPref.otpPushNotification = nil
            appRepositoy.setUserPreferences(userPref: userPref)
            return .ok(.expiredCode)
        } else {
            let remainingTime = max(0, min(Int((5 * 60) - remainingSeconds), 5 * 60))
            return .ok(.code(code: notification.code,
                             date: notification.sentDate,
                             remainingTime: remainingTime))
        }
    }
}

enum GetOtpPushNotificationUseCaseOkOutput {
    case noCode
    case expiredCode
    case code(code: String, date: Date, remainingTime: Int)
}
