//
//  CardDetailBuilder.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 5/8/21.
//

import CoreFoundationLib

final class CardDetailBuilder {
    private var values: [CardDetailProduct] = []
  
    func addPAN(pan: String?, isMasked: Bool) {
        guard let panString = pan else { return }
        let pan = CardDetailProduct(title: localized("cardDetail_label_cardNumber"),
                                    value: panString,
                                    type: .icon(masked: isMasked),
                                    dataType: .pan)
        values.append(pan)
    }
    
    func addAlias(alias: String) {
        let alias = CardDetailProduct(title: localized("productDetail_label_alias"),
                                      value: alias,
                                      type: .editable,
                                      dataType: .alias)
        values.append(alias)
    }
    
    func addDescription(description: String?) {
        guard let descriptionString = description else { return }
        let description = CardDetailProduct(title: localized("productDetail_label_description"),
                                            value: descriptionString,
                                            type: .basic,
                                            dataType: .description)
        values.append(description)
    }
    
    func addHolderName(holderName: String?) {
        
        guard let holderNameString = holderName else { return }
        let holderName = CardDetailProduct(title: localized("productDetail_label_holder"),
                                           value: holderNameString,
                                           type: .basic,
                                           dataType: .holder)
        values.append(holderName)
    }
    
    func addBeneficiary(beneficiary: String?) {
        guard let beneficiaryString = beneficiary else { return }
        let beneficiary = CardDetailProduct(title: localized("productDetail_label_beneficiary"),
                                            value: beneficiaryString,
                                            type: .basic,
                                            dataType: .beneficiary)
        values.append(beneficiary)
    }
    
    func addAccountLinked(accountLinked: String?) {
        guard let accountLinkedString = accountLinked else { return }
        let accountLinked = CardDetailProduct(title: localized("cardDetail_label_accountId"),
                                              value: accountLinkedString,
                                              type: .basic,
                                              dataType: .linkedAccount)
        values.append(accountLinked)
    }
    
    func addPaymentModality(paymentModality: String?, isCreditCard: Bool) {
        guard let paymentModalityString = paymentModality, isCreditCard else { return }
        let paymentModality = CardDetailProduct(title: localized("cardDetail_label_payMethod"),
                                                value: paymentModalityString,
                                                type: .basic,
                                                dataType: .paymentModality)
        values.append(paymentModality)
    }
    
    func addSituation(situation: String?) {
        guard let situationString = situation else { return }
        let situation = CardDetailProduct(title: localized("productDetail_label_status"),
                                          value: situationString,
                                          type: .basic,
                                          dataType: .situation)
        values.append(situation)
    }
    
    func addExpirationDate(expirationDate: String?) {
        guard let expirationDateString = expirationDate else { return }
        let expirationDate = CardDetailProduct(title: localized("cardDetail_label_expirationDate"),
                                               value: expirationDateString,
                                               type: .basic,
                                               dataType: .expirationDate)
        values.append(expirationDate)
    }
    
    func addStatus(status: String?) {
        guard let statusString = status else { return }
        let status = CardDetailProduct(title: localized("cardDetail_label_state"),
                                       value: statusString,
                                       type: .basic,
                                       dataType: .status)
        values.append(status)
    }

    func addType(type: String?) {
        guard let typeString = type else { return }
        let type = CardDetailProduct(title: localized("cardDetail_label_cardType"),
                                     value: typeString,
                                     type: .basic,
                                     dataType: .type)
        values.append(type)
    }

    func addCurrency(currency: String?) {
        guard let currencyString = currency else { return }
        let currency = CardDetailProduct(title: localized("productDetail_label_currency"),
                                     value: currencyString,
                                     type: .basic,
                                     dataType: .currency)
        values.append(currency)
    }

    func addCreditCardAccountNumber(creditCardAccountNumber: String?, isMasked: Bool) {
        guard let creditCardAccountNumberString = creditCardAccountNumber else { return }
        let creditCardAccountNumber = CardDetailProduct(title: localized("cardDetail_label_creditCardAccount"),
                                     value: creditCardAccountNumberString,
                                     type: .icon(masked: isMasked),
                                     dataType: .creditCardAccountNumber)
        values.append(creditCardAccountNumber)
    }

    func addInsurance(insurance: String?) {
        guard let insuranceString = insurance else { return }
        let insurance = CardDetailProduct(title: localized("productDetail_label_insurance"),
                                     value: insuranceString,
                                     type: .basic,
                                     dataType: .insurance)
        values.append(insurance)
    }

    func addInterestRate(interestRate: String?) {
        guard let interestRateString = interestRate else { return }
        let interestRate = CardDetailProduct(title: localized("productDetail_label_interestRate"),
                                     value: interestRateString,
                                     type: .basic,
                                     dataType: .interestRate)
        values.append(interestRate)
    }

    func addWithholdings(withholdings: String?) {
        guard let withholdingsString = withholdings else { return }
        let withholdings = CardDetailProduct(title: localized("productDetail_label_withholding"),
                                     value: withholdingsString,
                                     type: .basic,
                                     dataType: .withholdings)
        values.append(withholdings)
    }

    func addPreviousPeriodInterest(previousPeriodInterest: String?) {
        guard let previousPeriodInterestString = previousPeriodInterest else { return }
        let previousPeriodInterest = CardDetailProduct(title: localized("CardDetail_label_previousPeriodInterest"),
                                     value: previousPeriodInterestString,
                                     type: .basic,
                                     dataType: .previousPeriodInterest)
        values.append(previousPeriodInterest)
    }

    func addMinimumOutstandingDue(minimumOutstandingDue: String?) {
        guard let minimumOutstandingDueString = minimumOutstandingDue else { return }
        let minimumOutstandingDue = CardDetailProduct(title: localized("CardDetail_label_minimumOutstandingDue"),
                                     value: minimumOutstandingDueString,
                                     type: .basic,
                                     dataType: .minimumOutstandingDue)
        values.append(minimumOutstandingDue)
    }

    func addCurrentMinimumDue(currentMinimumDue: String?) {
        guard let currentMinimumDueString = currentMinimumDue else { return }
        let currentMinimumDue = CardDetailProduct(title: localized("CardDetail_label_currentMinimumDue"),
                                     value: currentMinimumDueString,
                                     type: .basic,
                                     dataType: .currentMinimumDue)
        values.append(currentMinimumDue)
    }

    func addTotalMinimumRepaymentAmount(totalMinimumRepaymentAmount: String?) {
        guard let totalMinimumRepaymentAmountString = totalMinimumRepaymentAmount else { return }
        let totalMinimumRepaymentAmount = CardDetailProduct(title: localized("CardDetail_label_totalMinimumRepaymentAmount"),
                                     value: totalMinimumRepaymentAmountString,
                                     type: .basic,
                                     dataType: .totalMinimumRepaymentAmount)
        values.append(totalMinimumRepaymentAmount)
    }

    func addLastStatementDate(lastStatementDate: String?) {
        guard let lastStatementDateString = lastStatementDate else { return }
        let lastStatementDate = CardDetailProduct(title: localized("CardDetail_label_lastStatementDate"),
                                     value: lastStatementDateString,
                                     type: .basic,
                                     dataType: .lastStatementDate)
        values.append(lastStatementDate)
    }

    func addNextStatementDate(nextStatementDate: String?) {
        guard let nextStatementDateString = nextStatementDate else { return }
        let nextStatementDate = CardDetailProduct(title: localized("CardDetail_label_nextStatementDate"),
                                     value: nextStatementDateString,
                                     type: .basic,
                                     dataType: .nextStatementDate)
        values.append(nextStatementDate)
    }

    func addActualPaymentDate(actualPaymentDate: String?) {
        guard let actualPaymentDateString = actualPaymentDate else { return }
        let actualPaymentDate = CardDetailProduct(title: localized("CardDetail_label_actualPaymentDate"),
                                     value: actualPaymentDateString,
                                     type: .basic,
                                     dataType: .actualPaymentDate)
        values.append(actualPaymentDate)
    }
    
    func build() -> [CardDetailProduct] {
        return self.values
    }
}
