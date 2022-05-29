//
//  SendMoneySummaryNoSepaPresenter.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 28/3/22.
//

import CoreFoundationLib

final class SendMoneySummaryNoSepaPresenter: SendMoneySummaryPresenter {
    override func getSummaryItems() -> [OneListFlowItemViewModel] {
        let builder = SendMoneySummaryContentBuilder(dependenciesResolver: self.dependenciesResolver, operativeData: self.operativeData)
        builder.addSender()
        builder.addNoSepaAmount()
        builder.addPaymentCosts()
        builder.addSendDate()
        builder.addSendType()
        builder.addNoSepaRecipient()
        return builder.buildHeaderSummary()
    }
    
    override func setupTransferAmount() {
        guard let amount = self.operativeData.noSepaTransferValidation?.settlementAmountPayerRepresentable else { return }
        let decorator = AmountRepresentableDecorator(
            amount,
            font: .typography(fontName: .oneH500Bold),
            decimalFont: .typography(fontName: .oneH300Bold)
        )
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
}
