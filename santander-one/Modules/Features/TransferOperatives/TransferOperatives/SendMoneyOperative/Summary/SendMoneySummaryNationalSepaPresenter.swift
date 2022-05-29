//
//  SendMoneySummaryNationalSepaPresenter.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 28/3/22.
//

import CoreFoundationLib

final class SendMoneySummaryNationalSepaPresenter: SendMoneySummaryPresenter {
    override func getSummaryItems() -> [OneListFlowItemViewModel] {
        let builder = SendMoneySummaryContentBuilder(dependenciesResolver: self.dependenciesResolver, operativeData: self.operativeData)
        builder.addSender()
        builder.addAmount()
        builder.addSendDate()
        builder.addSendType()
        builder.addRecipient()
        return builder.buildHeaderSummary()
    }
    
    override func setupTransferAmount() {
        guard let amount = self.operativeData.amount else { return }
        let decorator = AmountRepresentableDecorator(
            amount,
            font: .typography(fontName: .oneH500Bold),
            decimalFont: .typography(fontName: .oneH300Bold)
        )
        guard let formattedCurrency = decorator.getFormatedWithCurrencyName() else { return }
        self.view?.setTransferAmount(formattedCurrency)
    }
}
