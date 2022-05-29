//
//  CorePushNotificationsManager.swift
//  CorePushNotificationsService

import CoreFoundationLib
import UserNotifications

// TODO: model manager dependencies with a protocol like in NotificationServiceDependenciesProtocol
public protocol CorePushNotificationsManagerProtocol: AnyObject {
    func didReceivePushRequest(_ request: PushRequestable)
    func willPresentRequest(_ request: PushRequestable)
}

public final class CorePushNotificationsManager: CorePushNotificationsManagerProtocol {
    private let dependencies: DependenciesResolver
    private var launcher: CorePushLauncher?
    private var otpPushManager: OtpPushManagerProtocol?
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
        self.launcher = CorePushLauncher(dependenciesResolver: self.dependencies)
        self.otpPushManager = self.dependencies.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }
   
    /// Pass a push request to core
    public func didReceivePushRequest(_ request: PushRequestable) {
        switch request.didReceiveRequestAction {
        case .launchAction(let actionType):
            self.launcher?.executeActionForType(actionType)
        case .none:
            break
        }
    }
    
    public func willPresentRequest(_ request: PushRequestable) {
        switch request.willPresentRequestAction {
        case .otp:
            self.otpPushManager?.handleOTP()
        case .none:
            break
        }
    }
}
