//
//  BizumDetailMultipleBuilder.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 27/01/2021.
//

import Foundation
import CoreFoundationLib
import Operative
import UI

final class BizumDetailMultipleBuilder {
    private (set) var items: [BizumDetailItemsViewModel] = []
    private let bizumTransaction: BizumTransactionEntity
    private let ownerPhone: String?
    init(with bizumTransaction: BizumTransactionEntity) {
        self.bizumTransaction = bizumTransaction
        self.ownerPhone = bizumTransaction.checkPaymentEntity.phone?.trim()
    }

    func build() {
        self.addAmountAndConcept()
        self.addEmptyMultimedia()
        self.addOrigin()
        self.addTransferType()
        self.addReceiver()
    }

    func buildMultimedia(_ multimedia: BizumMultimediaData) -> [MultimediaType] {
        var items: [MultimediaType] = []
        if let image = multimedia.image {
            let item = MultimediaType.image(image, localized("addImage_label_viewImage"))
            items.append(item)
        }
        if let note = multimedia.note {
            let item = MultimediaType.note(note)
            items.append(item)
        }
        return items
    }
}

private extension BizumDetailMultipleBuilder {
    func addAmountAndConcept() {
        guard let amount = getTotalAmount(),
              let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32)).formatAsMillions() else { return }
        let item = ItemDetailAmountViewModel(
            title: TextWithAccessibility(text: getAmountTitle(), accessibility: AccessibilityBizumDetail.bizumLabelAmount),
            amount: amount,
            info: TextWithAccessibility(text: bizumTransaction.concept ?? "bizum_label_notConcept", accessibility: AccessibilityBizumDetail.bizumLabelConceptValue),
            stateLabel: TextWithAccessibility(text: bizumTransaction.stateType?.rawValueFormatted ?? "", accessibility: AccessibilityBizumDetail.bizumLabelStateValue),
            stateViewModel: BizumUtils.getViewModelStateType(bizumTransaction.stateType))
        item.setAmountStyle(moneyDecorator)
        item.setInfoStyle(LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .boldItalic, size: 14)))
        item.setAmountAccessibility(AccessibilityBizumDetail.bizumLabelAmountValue)
        self.items.append(.amount(item))
    }

    func getAmountTitle() -> String {
        if bizumTransaction.emitterType == BizumHomeOperationTypeViewModel.request {
            return  "bizumDetail_label_amountRequested"
        }
        return "bizumDetail_label_amount"
    }
    
    func addTransferType() {
        let item = ItemDetailViewModel(
            title: TextWithAccessibility(text: "bizumDetail_label_sendType", accessibility: AccessibilityBizumDetail.bizumLabelSenType),
            value: TextWithAccessibility(text: "bizumDetail_label_bizumNoCommissions",
                                         accessibility: AccessibilityBizumDetail.bizumLabelNoCommissions,
                                         style: LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text, type: .bold, size: 14))),
            info: TextWithAccessibility(text: bizumTransaction.date,
                                        accessibility: AccessibilityBizumDetail.bizumLabelDateValue,
                                        style: LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text, type: .regular, size: 12)))
        )
        self.items.append(.transferType(item))
    }

    func addOrigin() {
        guard let typeTransaction = self.bizumTransaction.typeTransaction else { return }
        var value: TextWithAccessibility? {
            if let emitterAlias = self.bizumTransaction.emitterAlias, !emitterAlias.isEmpty {
                return TextWithAccessibility(text: emitterAlias,
                                             accessibility: AccessibilityBizumDetail.bizumLabelEmitterValue,
                                             style: LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text, type: .bold, size: 14)))
            } else {
                return TextWithAccessibility(text: self.bizumTransaction.emitterId.tlfFormatted(),
                                             accessibility: AccessibilityBizumDetail.bizumLabelEmitterValue,
                                             style: LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text, type: .bold, size: 14)))
            }
        }
        var info: TextWithAccessibility? {
            guard let emitterAlias = self.bizumTransaction.emitterAlias, !emitterAlias.isEmpty else { return nil }
            return TextWithAccessibility(text: self.bizumTransaction.emitterId.tlfFormatted(),
                                         accessibility: AccessibilityBizumDetail.bizumLabelEmitterIdValue,
                                         style: LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text, type: .regular, size: 14)))
        }
        let item = ItemDetailViewModel(
            title: typeTransaction.getDetailTransactionTypeWithAccessibility(),
            value: value,
            info: info
        )
        self.items.append(.origin(item))
    }

    func addEmptyMultimedia() {
        self.items.append(.multimedia([]))
    }

    func addMediaIfNeeded() {
        guard let multimedia = self.bizumTransaction.multimedia else { return }
        var items: [MultimediaType] = []
        if let image = multimedia.image {
            let item = MultimediaType.image(image, localized("addImage_label_viewImage"))
            items.append(item)
        }
        if let note = multimedia.note {
            let item = MultimediaType.note(note)
            items.append(item)
        }
        self.items.append(.multimedia(items))
    }

    func addReceiver() {
        if self.bizumTransaction.receiversIds.count == 1 {
            self.addSimpleReceiver()
        } else {
            self.addMultipleReceiver()
        }
    }

    func formatReceiver(_ receiver: String) -> TextWithAccessibility {
        var text: String {
            let formatter = PhoneFormatter()
            if formatter.checkNationalPhone(phone: receiver) == .ok {
                return receiver.tlfFormatted()
            } else {
                return receiver
            }
        }
        let textStyle = TextWithAccessibility(text: text, accessibility: AccessibilityBizumDetail.bizumLabelDestination,
                                              style: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14)))
        return textStyle
    }

    func addSimpleReceiver() {
        let receiverAlias = self.bizumTransaction.receiverAlias.first ?? ""
        let receiver = receiverAlias.isEmpty ? self.bizumTransaction.receiversIds.first ?? "" : receiverAlias
        let title = TextWithAccessibility(text: "bizumDetail_label_destination", accessibility: AccessibilityBizumDetail.bizumLabelDestination)
        let item = self.formatReceiver(receiver)
        let receiverViewModel = ReceiverDetailViewModel(value: item)
        self.items.append(.recipients([receiverViewModel], title: title))
    }

    func addMultipleReceiver() {
        var receiversViewModel: [ReceiverDetailViewModel] = []
        let title = TextWithAccessibility(text: "bizumDetail_label_destination", accessibility: AccessibilityBizumDetail.bizumLabelDestination)
        self.bizumTransaction.operations?.forEach({ multipleDetail in
            let state = multipleDetail.dto.state
            let alias = multipleDetail.dto.receptorAlias ?? ""
            let receiver = multipleDetail.dto.receptorId ?? ""
            let value = self.formatMultipleReceiver(receiver, alias: alias)
            let info = TextWithAccessibility(text: state?.capitalized ?? "", accessibility: "",
                                             style: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12)))
            let moneyDecorator = MoneyDecorator(self.getAmount(), font: .santander(family: .text, type: .bold, size: 14), decimalFontSize: 14).getFormatedAbsWith1M()
            let amount = TextWithAccessibility(text: String(bizumTransaction.amount), accessibility: "", attribute: moneyDecorator)
            let receiverViewModel = ReceiverDetailViewModel(value: value, info: info, moneyDecorator: amount)
            receiversViewModel.append(receiverViewModel)
        })
        self.items.append(.recipients(receiversViewModel, title: title))
    }

    func formatMultipleReceiver(_ receiver: String, alias: String) -> TextWithAccessibility {
        var receiverID: String {
            let formatter = PhoneFormatter()
            if formatter.checkNationalPhone(phone: receiver) == .ok {
                return receiver.tlfFormatted()
            } else {
                return receiver
            }
        }
        let value = alias.isEmpty ? receiverID : alias
        let textStyle = TextWithAccessibility(text: value, accessibility: AccessibilityBizumDetail.bizumLabelDestination,
                                              style: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14)))
        return textStyle
    }

    func getAmount() -> AmountEntity {
        return AmountEntity(value: Decimal(bizumTransaction.amount))
    }

    func getTotalAmount() -> AmountEntity? {
        guard let transactionType = bizumTransaction.typeTransaction else { return nil }
        let amount = BizumUtils.getTotalAmount(bizumTransaction.amount, contacts: bizumTransaction.receiversIds.count, transactionType: transactionType)
        return amount
    }
}
