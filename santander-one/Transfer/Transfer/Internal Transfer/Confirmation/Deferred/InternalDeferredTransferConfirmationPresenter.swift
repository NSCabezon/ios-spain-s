//
//  InternalTransferDeferredConfirmationPresenter.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 08/01/2020.
//

import Foundation
import CoreFoundationLib

final class InternalDeferredTransferConfirmationPresenter: InternalTransferConfirmationPresenter {

    override func setupConfirmationItems() {
        let builder = InternalDeferredTransferConfirmationBuilder(internalTransfer: self.operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAmount(action: self.confirmationItemAction(.amount))
        builder.addConcept(action:
            self.confirmationItemAction(.concept))
        builder.addOriginAccount(action: self.confirmationItemAction(.originAccount))
        builder.addTransferType()
        builder.addPeriodicityInfo(action: self.confirmationItemAction(.periodicity))
        builder.addDeferredDate(action: self.confirmationItemAction(.date))
        builder.addDestinationAccount(action: self.confirmationItemAction(.destinationAccount))
        self.view?.add(builder.build())
        guard let totalAmount = self.operativeData.internalTransfer?.netAmount else { return }
        self.view?.addTotalOperationAmount(totalAmount)
    }
    
    override func didSelectContinue() {
        self.validateData()
    }
}

private extension InternalDeferredTransferConfirmationPresenter {
    
    func validateData() {
        guard
            let originAccount = self.operativeData.selectedAccount,
            let destinationAccount = self.operativeData.destinationAccount,
            let amount = self.operativeData.amount,
            let transferTime = self.operativeData.time
        else {
            return
        }
        self.view?.showLoading()
        let input = ConfirmScheduledInternalTransferUseCaseInput(
            originAccount: originAccount,
            destinationAccount: destinationAccount,
            amount: amount,
            concept: self.operativeData.concept,
            transferTime: transferTime,
            scheduledTransfer: self.operativeData.scheduledTransfer
        )
        UseCaseWrapper(
            with: self.dependenciesResolver.resolve(for: ConfirmDeferredInternalTransferUseCase.self).setRequestValues(requestValues: input),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.view?.dismissLoading {
                    self.operativeData.scheduledTransfer = result.scheduledTransfer
                    self.operativeData.internalTransfer = result.internalTransfer
                    self.container?.save(result.scaEntity)
                    self.container?.rebuildSteps()
                    self.container?.save(self.operativeData)
                    self.container?.stepFinished(presenter: self)
                }
            },
            onError: { [weak self] errorResult in
                self?.view?.dismissLoading {
                    guard let self = self else { return }
                    self.view?.showDialog(
                        withDependenciesResolver: self.dependenciesResolver,
                        description: errorResult.getErrorDesc()
                    )
                }
            }
        )
    }
}
