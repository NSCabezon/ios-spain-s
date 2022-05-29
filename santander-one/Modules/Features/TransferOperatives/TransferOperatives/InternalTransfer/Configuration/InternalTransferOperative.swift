//
//  InternalTransferOperative.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 7/2/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import Operative
import CoreFoundationLib

final class InternalTransferOperative: ReactiveOperative, DataBindable {
    private unowned let dependencies: InternalTransferOperativeDependenciesResolver
    var subscriptions: Set<AnyCancellable> = []
    var willStartConditions: [AnyPublisher<ConditionState, Never>] = []
    var willFinishConditions: [AnyPublisher<ConditionState, Never>] = []
    var willShowNextConditions: [AnyPublisher<ConditionState, Never>] = []
    
    var navigationBarBuilder: OneNavigationBarCapability<InternalTransferOperative>.Builder {
        return OneNavigationBarCapability<InternalTransferOperative>.Builder()
            .addTitle { step in
                switch step {
                case .selectAccount:
                    return "toolbar_title_originAccount"
                case .destinationAccount:
                    return "toolbar_title_destinationAccounts"
                case .amount:
                    return "toolbar_title_amountAndDate"
                case .confirmation:
                    return "genericToolbar_title_confirmation"
                case .summary:
                    return "genericToolbar_title_summary"
                }
            }
            .addLeftAction { step in
                switch step {
                case .summary:
                    return .none
                default:
                    return .back
                }
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
            shouldShowProgress: { step in
                switch step {
                case .summary:
                    return false
                case .destinationAccount, .amount, .selectAccount, .confirmation:
                    return true
                }
            }
        ).asAnyCapability()
    }
    
    var giveUpDialogCapability: AnyCapability {
        return DefaultGiveUpDialogCapability(operative: self).asAnyCapability()
    }
    
    var giveUpOpinatorCapability: AnyCapability {
        return DefaultGiveUpOpinatorCapability(
            operative: self,
            opinatorCoordinator: dependencies.external.opinatorCoordinator(),
            giveUpOpinator: GiveUpOpinatorInfoEntity(path: "app-traspasos-abandono")
        ).asAnyCapability()
    }
    
    lazy var capabilities: [AnyCapability] = {
        return [
            navigationBarCapability,
            setupCapability,
            progressBarCapability,
            giveUpDialogCapability,
            giveUpOpinatorCapability
        ]
    }()
    
    static var steps: [StepsCoordinator<InternalTransferStep>.Step] {
        return [
            .step(.selectAccount),
            .step(.destinationAccount),
            .step(.amount),
            .step(.confirmation),
            .step(.summary)
        ]
    }
    
    init(dependencies: InternalTransferOperativeDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    var coordinator: OperativeCoordinator {
        return dependencies.resolve()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    var stepsCoordinator: StepsCoordinator<InternalTransferStep> {
        return dependencies.resolve()
    }
    
    var setupCapability: AnyCapability {
        return InternalTransferSetupCapability(operative: self, dependencies: dependencies.external).asAnyCapability()
    }
}
