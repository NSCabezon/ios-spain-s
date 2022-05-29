//
//  SendMoneyConfirmationNoSepaPresenter.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 8/3/22.
//

import CoreFoundationLib
import CoreDomain

final class SendMoneyConfirmationNoSepaPresenter: SendMoneyConfirmationPresenter {
    
    override func getConfirmationItemsViewModels() -> [OneListFlowItemViewModel] {
        let builder = SendMoneyConfirmationBuilder(dependenciesResolver: self.dependenciesResolver,
                                                   operativeData: self.operativeData)
        builder.addSender { self.goToAccountSelector() }
        builder.addNoSepaAmount { self.goToAmountAndDate() }
        builder.addPaymentCosts { self.goToAmountAndDate() }
        builder.addSendDate()
        builder.addSendType()
        builder.addNoSepaRecipient { self.goToDestinationAccount() }
        return builder.build()
    }
    
    override func setupTransferAmount() {
        guard let amount = self.operativeData.noSepaTransferValidation?.settlementAmountPayerRepresentable else { return }
        let decorator = AmountRepresentableDecorator(amount, font: .typography(fontName: .oneH500Bold), decimalFont: .typography(fontName: .oneH200Bold))
        guard let formattedCurrency = decorator.getFormatedWithCurrencyName() else { return }
        self.view?.setTransferAmount(formattedCurrency)
    }
    
    override func getCostWaringLabel() -> String? {
        var text: String = localized("sendMoney_label_takeMind")
        text.append("\n")
        text.append(localized("sendMoney_label_exchangeRateNonEuro"))
        text.append("\n")
        if self.operativeData.expenses?.showsWarning ?? true {
            text.append(localized("sendMoney_label_amountReceivedRecipient"))
            text.append("\n")
        }
        text.append(localized("sendMoney_label_paymentFees"))
        return text
    }
    
    override func didTapOnContinue() {
        let provider: SendMoneyUseCaseProviderProtocol = self.dependenciesResolver.resolve()
        let useCase = provider.getConfirmationNoSepaUseCase()
        self.view?.showLoading()
        Scenario(useCase: useCase, input: self.operativeData)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] operativeData in
                guard let self = self else { return }
                self.view?.hideLoading()
                self.container?.clearParametersOfType(type: SCARepresentable.self)
                if let scaRepresentable = operativeData.scaRepresentable {
                    self.container?.save(scaRepresentable)
                }
                self.container?.rebuildSteps()
                self.container?.stepFinished(presenter: self)
            }
            .onError { [weak self] _ in
                self?.view?.hideLoading()
                self?.container?.showGenericError()
            }
    }
}

private extension SendMoneyConfirmationNoSepaPresenter {
    func goToAmountAndDate() {
        self.container?.back(to: SendMoneyAmountNoSepaPresenter.self)
    }
}
