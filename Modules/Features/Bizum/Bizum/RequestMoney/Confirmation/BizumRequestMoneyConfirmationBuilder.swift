//
//  BizumRequestMoneyConfirmationBuilder.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 08/12/2020.
//

import CoreFoundationLib
import Operative
import UI
import ESUI

class BizumRequestMoneyConfirmationBuilder {
    
    private let data: BizumRequestMoneyOperativeData
    private var items: [BizumConfirmationItemViewModel] = []
    let dependenciesResolver: DependenciesResolver
    
    required init(data: BizumRequestMoneyOperativeData, dependenciesResolver: DependenciesResolver) {
        self.data = data
        self.dependenciesResolver = dependenciesResolver
    }
    
    func build() -> [BizumConfirmationItemViewModel] {
        return self.items
    }
    
    func addAmountAndConcept(action: @escaping () -> Void) {
        guard let amount = self.data.bizumSendMoney?.totalAmount,
            let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32)).getFormatedAbsWith1M() else { return }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_label_totalAmount"),
            value: moneyDecorator,
            position: .first,
            info: NSAttributedString(string: self.getOperationConcept()),
            action: ConfirmationItemAction(title: localized("generic_edit_link"), action: action),
            accessibilityIdentifier: AccessibilityOtherOperatives.lblConfirmationAmount.rawValue
        )
        self.items.append(.confirmation(item: item))
    }
    
    func addMedia() {
        var viewModels: [ImageLabelViewModel] = []
        if let image = self.data.multimediaData?.image {
            let item = ImageLabelViewModel(imageSize: CGSize(width: 24.0, height: 24.0), image: UIImage(data: image), text: localized("toolbar_title_attachedImage"))
            viewModels.append(item)
        }
        if let note = self.data.multimediaData?.note {
            let item = ImageLabelViewModel(imageSize: CGSize(width: 32.0, height: 32.0), image: ESAssets.image(named: "icnNotes"), text: note)
            viewModels.append(item)
        }
        self.items.append(.multimedia(item: viewModels))
    }
    
    func addContacts(action: @escaping () -> Void) {
        let item = ConfirmationContainerViewModel(title: localized("confirmation_label_destination"),
                                                  position: .last,
                                                  action: ConfirmationContainerAction(title: localized("generic_edit_link"), action: action),
                                                  views: [])
        self.items.append(.contacts(item: item))
    }
    
    func addTotal() {
        guard let amount = self.data.bizumSendMoney?.totalAmount else { return }
        let item = ConfirmationTotalOperationItemViewModel(amountEntity: amount)
        self.items.append(.total(time: item))
    }
    
}

private extension BizumRequestMoneyConfirmationBuilder {
    func getOperationConcept() -> String {
        guard let concept = self.data.bizumSendMoney?.concept, !concept.isEmpty else {
            return localized("bizum_label_notConcept")
        }
        return concept
    }
}
