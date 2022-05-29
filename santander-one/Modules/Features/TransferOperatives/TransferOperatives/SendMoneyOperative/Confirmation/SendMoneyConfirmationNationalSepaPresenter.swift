//
//  SendMoneyConfirmationNationalSepaPresenter.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 8/3/22.
//

import CoreFoundationLib
import CoreDomain

final class SendMoneyConfirmationNationalSepaPresenter: SendMoneyConfirmationPresenter {

    override func getConfirmationItemsViewModels() -> [OneListFlowItemViewModel] {
        let builder = SendMoneyConfirmationBuilder(dependenciesResolver: self.dependenciesResolver, operativeData: self.operativeData)
        builder.addSender(action: self.goToAccountSelector)
        builder.addAmount(action: self.goToAmountAndDate)
        builder.addSendDate(action: self.goToSendDate)
        builder.addSendType(action: self.goToSendType)
        builder.addRecipient(action: self.goToDestinationAccount)
        return builder.build()
    }
    
    override func setupTransferAmount() {
        guard let amount = self.operativeData.amount else { return }
        let decorator = AmountRepresentableDecorator(
            amount,
            font: .typography(fontName: .oneH500Bold),
            decimalFont: .typography(fontName: .oneH200Bold)
        )
        guard let formattedCurrency = decorator.getFormatedWithCurrencyName() else { return }
        self.view?.setTransferAmount(formattedCurrency)
    }
    
    override func getCostWaringLabel() -> String? {
        nil
    }
    
    override func didTapOnContinue() {
        let provider: SendMoneyUseCaseProviderProtocol = self.dependenciesResolver.resolve()
        let useCase = provider.getConfirmationUseCase()
        self.view?.showLoading()
        Scenario(useCase: useCase, input: self.operativeData)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                guard let self = self else { return }
                self.container?.clearParametersOfType(type: SCARepresentable.self)
                if let scaRepresentable = response.scaRepresentable {
                    self.container?.save(scaRepresentable)
                }
                self.container?.save(response)
                self.view?.hideLoading()
                self.container?.rebuildSteps()
                guard let scaRepresentable = self.operativeData.scaRepresentable,
                      scaRepresentable.mapSCA() is OAPEntity else {
                          self.container?.stepFinished(presenter: self)
                          return
                      }
            }
            .onError { [weak self] error in
                guard let self = self else { return }
                self.view?.hideLoading()
                self.view?.showGenericErrorDialog(withDependenciesResolver: self.dependenciesResolver)
            }
    }
}

private extension SendMoneyConfirmationNationalSepaPresenter {
    func goToAmountAndDate() {
        self.container?.back(to: SendMoneyAmountPresenter.self)
    }
    
    func goToSendType() {
        self.container?.back()
    }
}
