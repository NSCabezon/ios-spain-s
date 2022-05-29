//
//  SKOperative.swift
//  Alamofire
//
//  Created by Andres Aguirre Juarez on 21/2/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import Operative
import CoreFoundationLib
import SANLegacyLibrary
import ESUI

public final class SKOperative: ReactiveOperative, DataBindable {
    
    private let dependencies: SKOperativeDependenciesResolver
    public var subscriptions: Set<AnyCancellable> = []
    public var willStartConditions: [AnyPublisher<ConditionState, Never>] = []
    public var willFinishConditions: [AnyPublisher<ConditionState, Never>] = []
    public var willShowNextConditions: [AnyPublisher<ConditionState, Never>] = []
    private let biometricsManager: LocalAuthenticationPermissionsManagerProtocol
    @BindingOptional var operativeData: SKOnboardingOperativeData!

    var navigationBarBuilder: OneNavigationBarCapability<SKOperative>.Builder {
            return OneNavigationBarCapability<SKOperative>.Builder()
                .addTitle { _ in
                    return "ecommerce_label_SantanderKeyOneLine"
                }
                .addTitleImage { _ in
                    if let image = ESAssets.image(named: "IcnSanKeyLock")?.withRenderingMode(.alwaysTemplate) {
                        image.accessibilityIdentifier = "IcnSanKeyLock"
                        return .image(image)
                    } else {
                        return .key("IcnSanKeyLock")
                    }
                }
                .addLeftAction { step in
                    switch step {
                    case .deviceAlias:
                        return .none
                    default:
                        return .back
                    }
                }
                .addRightActions { step in
                    switch step {
                    case .deviceAlias, .selectCard, .biometrics:
                        return []
                    default:
                        return [.close]
                    }
                }
                .addTitleConfiguration { _ in
                    return LocalizedStylableTextConfiguration(font: .santander(family: .text,
                                                                               type: .regular,
                                                                               size: 18),
                                                              alignment: .center)
                }
        }

        var navigationBarCapability: AnyCapability {
            return OneNavigationBarCapability(
                operative: self,
                configuration: navigationBarBuilder.build()
            ).asAnyCapability()
        }

    var setupCapability: AnyCapability {
        return SKOnboardingSetupCapability(
            operative: self,
            dependencies: dependencies.external
        ).asAnyCapability()
    }

    var progressBarCapability: AnyCapability {
        return DefaultProgressBarCapability(
            operative: self,
            progressBarType: .oneContinuous,
            shouldShowProgress: { _ in
                return true
            }
        ).asAnyCapability()
    }
    
    var giveUpDialogCapability: AnyCapability {
        return DefaultGiveUpDialogCapability(
            operative: self
        ).asAnyCapability()
    }
    
    lazy public var capabilities: [AnyCapability] = {
       return [
            navigationBarCapability,
            setupCapability,
            progressBarCapability,
            giveUpDialogCapability
       ]
    }()

    static var steps: [StepsCoordinator<SKOperativeStep>.Step] {
        return [
            .step(.deviceAlias),
            .step(.selectCard), // PIN
            .step(.pin), // PIN
            .step(.signature), // SIGN
            .step(.otp),
            .step(.biometrics)
        ]
    }
    
    init(dependencies: SKOperativeDependenciesResolver) {
        self.dependencies = dependencies
        self.biometricsManager = dependencies.external.resolve()
        self.suscribeStepFinished()
    }

    public func configureSteps() {
        guard let data: SKOnboardingOperativeData? = dataBinding.get(),
              let auth = data?.authMethod else { return }
        if auth == .pin {
            stepsCoordinator.remove(step: .signature)
        } else if auth == .sign {
            stepsCoordinator.remove(step: .selectCard)
            stepsCoordinator.remove(step: .pin)
        }
        if self.biometricsManager.isTouchIdEnabled {
            stepsCoordinator.remove(step: .biometrics)
        }
    }
    
    func suscribeStepFinished() {
        stepsCoordinator.willFinishPublisher
            .sink { [unowned self] _ in
                guard let onFinish = coordinator.onFinish else {
                    return
                }
                onFinish()
            }.store(in: &subscriptions)
    }
    
    public var coordinator: OperativeCoordinator {
        return dependencies.resolve()
    }
    
    public var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    public var stepsCoordinator: StepsCoordinator<SKOperativeStep> {
        return dependencies.resolve()
    }
}
