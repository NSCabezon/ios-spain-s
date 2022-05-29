//
//  BizumRegistrationOperative.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 25/4/22.
//

import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import Operative
import UI

public final class BizumRegistrationOperative: ReactiveOperative, DataBindable {
    private let dependencies: BizumRegistrationOperativeDependenciesResolver
    public var subscriptions: Set<AnyCancellable> = []
    public var willStartConditions: [AnyPublisher<ConditionState, Never>] = []
    public var willFinishConditions: [AnyPublisher<ConditionState, Never>] = []
    public var willShowNextConditions: [AnyPublisher<ConditionState, Never>] = []
    @BindingOptional var operativeData: BizumRegistrationOperativeData!

    var navigationBarBuilder: OneNavigationBarCapability<BizumRegistrationOperative>.Builder {
        return OneNavigationBarCapability<BizumRegistrationOperative>.Builder()
            .addTitle { _ in
                return "toolbar_title_originAccount"
            }
            .addRightActions { _ in
                return [.close]
            }
    }

    var navigationBarCapability: AnyCapability {
        return OneNavigationBarCapability(
            operative: self,
            configuration: navigationBarBuilder.build()
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
            progressBarCapability,
            giveUpDialogCapability
       ]
    }()

    static var steps: [StepsCoordinator<BizumRegistrationOperativeStep>.Step] {
        return [
            .step(.selectAccount), // Accunt
            .step(.pin), // PIN
            .step(.signature), // SIGN
            .step(.otp),
            .step(.resume)
        ]
    }
    
    init(dependencies: BizumRegistrationOperativeDependenciesResolver) {
        self.dependencies = dependencies
        self.suscribeStepFinished()
    }

    public func configureSteps() {
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
    
    public var stepsCoordinator: StepsCoordinator<BizumRegistrationOperativeStep> {
        return dependencies.resolve()
    }
}
