//
//  SendMoneyOperativeViewModel.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 5/1/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import Operative
import CoreFoundationLib

final class SendMoneyOperative: ReactiveOperative, DataBindable {

    private let dependencies: SendMoneyOperativeDependenciesResolver
    var subscriptions: Set<AnyCancellable> = []
    var willStartConditions: [AnyPublisher<ConditionState, Never>] = []
    var willFinishConditions: [AnyPublisher<ConditionState, Never>] = []
    var willShowNextConditions: [AnyPublisher<ConditionState, Never>] = []
    
    var navigationBarCapability: AnyCapability {
        return DefaultNavigationBarCapability(
            operative: self,
            navigationBarDependencies: dependencies.resolve(),
            configuration: navigationBarBuilder.build()
        ).asAnyCapability()
    }
    
    var navigationBarBuilder: DefaultNavigationBarCapability<SendMoneyOperative>.Builder {
        return DefaultNavigationBarCapability<SendMoneyOperative>.Builder()
            .addTitle { _ in
                return .title(key: "SendMoney")
            }
            .addLeftAction { _ in
                return .back
            }
            .addRightActions { _ in
                return [.close]
            }
    }
    
    var setupCapability: AnyCapability {
        return SendMoneySetupCapability(operative: self).asAnyCapability()
    }
    
    var progressBarCapability: AnyCapability {
        return DefaultProgressBarCapability(
            operative: self,
            progressBarType: .stepped,
            shouldShowProgress: { _ in
                return true
            }
        ).asAnyCapability()
    }
    
    var giveUpDialogCapability: AnyCapability {
        return DefaultGiveUpDialogCapability(operative: self).asAnyCapability()
    }
    
    var giveUpOpinatorCapability: AnyCapability {
        return DefaultGiveUpOpinatorCapability(
            operative: self,
            opinatorCoordinator: dependencies.resolveOpinatorCoordinator(),
            giveUpOpinator: GiveUpOpinatorInfoEntity(path: "")
        ).asAnyCapability()
    }
    
    var shouldShowStepCapability: AnyCapability {
        return ShouldShowStepCapability(
            operative: self,
            shouldShowStep: { _ in
                return true
            }
        ).asAnyCapability()
    }
    var scaCapability: AnyCapability {
        return SendMoneySCACapability(operative: self).asAnyCapability()
    }
    
    lazy var capabilities: [AnyCapability] = {
       return [
            navigationBarCapability,
            setupCapability,
            progressBarCapability,
            giveUpDialogCapability,
            giveUpOpinatorCapability,
            shouldShowStepCapability,
            scaCapability
       ]
    }()
    static var steps: [StepsCoordinator<SendMoneyStep>.Step] {
        return [
            .step(.selectAccount),
            .step(.selectDestination)
        ]
    }
    
    init(dependencies: SendMoneyOperativeDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    var coordinator: OperativeCoordinator {
        return dependencies.resolve()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    var stepsCoordinator: StepsCoordinator<SendMoneyStep> {
        return dependencies.resolve()
    }
}
