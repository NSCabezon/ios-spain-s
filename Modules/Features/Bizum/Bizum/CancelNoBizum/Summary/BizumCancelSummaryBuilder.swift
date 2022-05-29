import Foundation
import Operative
import CoreFoundationLib
import ESUI

final class BizumCancelSummaryBuilder {
    
    private let operativeData: BizumCancelOperativeData
    private var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private let dependenciesResolver: DependenciesResolver
    private let bizumOperationEntity: BizumOperationEntity?
    
    init(operativeData: BizumCancelOperativeData, dependenciesResolver: DependenciesResolver) {
        self.operativeData = operativeData
        self.dependenciesResolver = dependenciesResolver
        self.bizumOperationEntity = self.operativeData.operationEntity.bizumOperationEntity
    }
    
    // MARK: Content
    func addAmountAndConcept() {
        guard let amount = self.bizumOperationEntity?.amount,
              let moneyDecorator = MoneyDecorator(AmountEntity(value: Decimal(amount)), font: .santander(family: .text, type: .bold, size: 32)).getFormatedAbsWith1M() else { return }
        let concept: String = self.bizumOperationEntity?.concept ?? localized("bizum_label_notConcept").text
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_label_totalAmount"), subTitle: moneyDecorator, info: concept, accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryAmount.rawValue)
        self.bodyItems.append(item)
    }
    
    func addSendingDate() {
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("confirmation_item_shippingDate"), subTitle: self.bizumOperationEntity?.date?.operativeDetailDate() ?? "", accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryDate.rawValue)
        self.bodyItems.append(item)
    }
    
    func addDestinationPhone() {
        let phone = self.bizumOperationEntity?.receptorId?.tlfFormatted() ?? ""
        let phoneFormatted = BizumUtils.boldBulletAttributedString(phone)
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_label_destination"), subTitle: phoneFormatted, accessibilityIdentifier: AccessibilityOtherOperatives.lblSummaryDestination.rawValue)
        self.bodyItems.append(item)
    }
    
    // MARK: Footer
    func addGoToBizumHome(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            image: ESAssets.image(named: "icnBizumSummary"),
            title: localized("generic_button_anotherSendMoney"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func addGoToGlobalPosition(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnHome",
            title: localized("generic_button_globalPosition"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func addGoToOpinator(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnLike",
            title: localized("generic_button_improve"),
            action: action
        )
        self.footerItems.append(viewModel)
    }
    
    func build() -> OperativeSummaryStandardViewModel {
        return OperativeSummaryStandardViewModel(
            header: OperativeSummaryStandardHeaderViewModel(image: "icnCheckOval1", title: localized("summe_title_perfect"), description: localized("summary_item_successfullyCanceled"), extraInfo: nil),
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}
