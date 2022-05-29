//
//  ReactiveOperativeMocks.swift
//  Operative-Unit-Tests
//
//  Created by David Gálvez Alonso on 28/3/22.
//

import CoreFoundationLib
import OpenCombine
import UI

@testable import Operative

internal enum TestStep: Equatable {
    case signature
    case otp
}

final class MockOTPPushManager: OtpPushManagerProtocol {
    func handleOTP() { fatalError() }
    func registerOtpHandler(handler: OtpNotificationHandler) { fatalError() }
    func unregisterOtpHandler() { fatalError() }
    func removeOtpFromUserPref() { fatalError() }
    func didRegisterForRemoteNotifications(deviceToken: Data) { fatalError() }
    func registerOtpPushAndSaveToken(deviceId: String) { fatalError() }
    func getDeviceToken() -> Data? { fatalError() }
    
    func updateToken(completion: @escaping ((_ isNew: Bool, _ returnCode: CoreFoundationLib.ReturnCodeOTPPush?) -> Void)) {
        completion(true, nil)
    }
}

final class MockAPPNotificationManagerBridge: APPNotificationManagerBridgeProtocol {
    func getOtpPushManager() -> OtpPushManagerProtocol? {
        return MockOTPPushManager()
    }
}

final class MockOTPStrategy: OTPCapabilityStrategy {
    
    let operative: MockOperative
    let validateStep: TestStep = .signature
    var otpStep: TestStep = .otp
    
    var otpPublisher: Deferred<AnyPublisher<Void, Error>> {
        return Deferred {
            Future { promise in
                let blockedError = GenericErrorOTPErrorOutput("Ha ocurrido un error. Debe reintentar la operación.", .otpRevoked, "")
                promise(.failure(blockedError))
            }.eraseToAnyPublisher()
        }
    }
    
    public init(operative: MockOperative) {
        self.operative = operative
    }
}

final class MockOperative: ReactiveOperative {

    private var dependencies: MockReactiveOperativeExternalDependenciesResolver
    public var showProgress: Bool = true
    var subscriptions: Set<AnyCancellable> = []
    var willStartConditions: [AnyPublisher<ConditionState, Never>] = []
    var willFinishConditions: [AnyPublisher<ConditionState, Never>] = []
    var willShowNextConditions: [AnyPublisher<ConditionState, Never>] = []
    
    static var steps: [StepsCoordinator<TestStep>.Step] {
        return [
            .step(.signature),
            .step(.otp)
        ]
    }
    
    var stepsCoordinator: StepsCoordinator<TestStep> {
        fatalError()
    }
    
    var capabilities: [AnyCapability] = []
    
    var coordinator: OperativeCoordinator {
        return dependencies.resolve()
    }
    
    func start() {}
    func next() {}
    func back() {}
    func finish() {}
    func back(to step: TestStep) {}
    
    init(dependencies: MockReactiveOperativeExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
}

final class MockSignatureStrategy: SignatureCapabilityStrategy {
    
    let operative: MockOperative
    let validateStep: TestStep = .signature
    let signatureStep: TestStep = .signature
    var signaturePublisher: Deferred<AnyPublisher<Void, Error>> {
        return Deferred {
            Future { promise in
                let revokedError = GenericErrorSignatureErrorOutput("Ha ocurrido un error. Debe reintentar la operación.", .revoked, "")
                promise(.failure(revokedError))
            }.eraseToAnyPublisher()
        }
    }
    
    public init(operative: MockOperative) {
        self.operative = operative
    }
}

public protocol MockReactiveOperativeExternalDependenciesResolver {
    func resolve() -> OperativeCoordinator
}
