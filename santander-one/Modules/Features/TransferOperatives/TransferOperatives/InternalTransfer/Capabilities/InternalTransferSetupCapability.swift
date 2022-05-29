//
//  InternalTransferSetupCapabilities.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 15/2/22.
//

import Foundation
import Operative
import OpenCombine
import UIOneComponents
import CoreFoundationLib

final class InternalTransferSetupCapability: WillStartCapability {
    let operative: InternalTransferOperative
    let dependencies: InternalTransferOperativeExternalDependenciesResolver
    var useCase: InternalTransferPreSetupUseCase {
        return dependencies.resolve()
    }
    
    init(operative: InternalTransferOperative, dependencies: InternalTransferOperativeExternalDependenciesResolver) {
        self.operative = operative
        self.dependencies = dependencies
    }
    
    var willStartPublisher: AnyPublisher<ConditionState, Never> {
        return showLoadingPublisher()
            .flatMap { [unowned self] in
                self.useCase.fetchPreSetup()
            }
            .flatMap { [unowned self] in
                self.dismissLoadingPublisher($0)
            }
            .handleEvents(
                receiveOutput: { [unowned self] in
                    self.setOperativeData($0)
                },
                receiveCompletion: { [unowned self] in
                    self.onReceivedStartPublisher($0)
                }
            )
            .map { _ in
                return .success
            }
            .replaceError(with: .failure)
            .eraseToAnyPublisher()
    }
}

private extension InternalTransferSetupCapability {
    func showLoadingPublisher() -> AnyPublisher<Void, Never> {
        return operative.coordinator.showLoadingPublisher()
            .eraseToAnyPublisher()
    }
    
    func dismissLoadingPublisher(_ preSetupData: PreSetupData) -> AnyPublisher<PreSetupData, Never> {
        return operative.coordinator.dismissLoadingPublisher()
            .flatMap { Just(preSetupData) }
            .eraseToAnyPublisher()
    }
    
    func setOperativeData(_ preSetupData: PreSetupData) {
        let operativeData = InternalTransferOperativeData()
        operativeData.originAccountsNotVisibles = preSetupData.originAccountsNotVisibles
        operativeData.originAccountsVisibles = preSetupData.originAccountsVisibles
        operativeData.destinationAccountsVisibles = preSetupData.destinationAccountsVisibles
        operativeData.destinationAccountsNotVisibles = preSetupData.destinationAccountsNotVisibles
        operative.coordinator.dataBinding.set(operativeData)
    }
    
    func onReceivedStartPublisher(_ subscribers: Subscribers.Completion<InternalTransferOperativeError>) {
        switch subscribers {
        case .finished: break
        case .failure(let error):
            operative.coordinator.dismissLoading() { [unowned self] in
                let internalCoordinator: InternalTransferOperativeCoordinator = self.dependencies.resolve()
                internalCoordinator.showInternalTransferError(error)
            }
        }
    }
}
