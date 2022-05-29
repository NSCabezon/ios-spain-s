import CoreFoundationLib
import Foundation
import Operative

final class SummaryAmortizationStepBuilder {
    private var bodyItems: [OperativeSummaryStandardBodyItemViewModel] = []
    private var footerItems: [OperativeSummaryStandardFooterItemViewModel] = []
    private var bodyActionItems: [OperativeSummaryStandardBodyActionViewModel] = []
    private var viewModel: SummaryAmortizationViewModel?
    private let dependenciesResolver: DependenciesResolver

    init(viewModel: SummaryAmortizationViewModel?, dependenciesResolver: DependenciesResolver) {
        self.viewModel = viewModel
        self.dependenciesResolver = dependenciesResolver
    }

    // MARK: Body

    func addLoanAmount() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_amortizationAmount"), subTitle: viewModel.loanAmount)
        self.bodyItems.append(item)
    }

    func addLoanAlias() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_loans"), subTitle: viewModel.loanAlias.capitalized)
        self.bodyItems.append(item)
    }

    func addLoanContractNumber() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("confirmation_item_contract"), subTitle: viewModel.loanContractNumber)
        self.bodyItems.append(item)
    }

    func addHolder() {
        guard let viewModel = self.viewModel else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.santander(family: .text, type: .regular, size: 12)]
        let attributedText = NSAttributedString(string: viewModel.iban, attributes: attributes)
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_holder"), subTitle: viewModel.loanHolderName, info: attributedText)
        self.bodyItems.append(item)
    }

    func addPending() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_pendingAmount_without"), subTitle: viewModel.pendingAmount)
        self.bodyItems.append(item)
    }

    func addExpiringDate() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_expiryDate"), subTitle: viewModel.loanExpiringDate)
        self.bodyItems.append(item)
    }

    func addInitialLimit() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_startLimit"), subTitle: viewModel.initialLimit)
        self.bodyItems.append(item)
    }

    func addAmortizationType() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_applyFor"), subTitle: viewModel.amortizationType)
        self.bodyItems.append(item)
    }

    func addValueDate() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_valueDate"), subTitle: viewModel.loanValueDate)
        self.bodyItems.append(item)
    }

    func addAmortizationAmount() {
        guard let viewModel = self.viewModel else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_settlementAmount"), subTitle: viewModel.amortizationAmount)
        self.bodyItems.append(item)
    }

    func addFinantialLoss() {
        guard let viewModel = self.viewModel, let loss = viewModel.finantialLoss else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_financialLoss"), subTitle: loss)
        self.bodyItems.append(item)
    }

    func addCompensation() {
        guard let viewModel = self.viewModel, let compensation = viewModel.compensation else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_compensation"), subTitle: compensation)
        self.bodyItems.append(item)
    }

    func addNewInsuranceFee() {
        guard let viewModel = self.viewModel, let fee = viewModel.insuranceFee else { return }
        let item = OperativeSummaryStandardBodyItemViewModel(title: localized("summary_item_newInsurance"), subTitle: fee)
        self.bodyItems.append(item)
    }

    // MARK: Body actions

    func addShare(withAction action: @escaping () -> Void) {
        let viewModel = OperativeSummaryStandardBodyActionViewModel(
            image: "icnShare",
            title: localized("generic_button_share"),
            action: action
        )
        self.bodyActionItems.append(viewModel)
    }

    // MARK: Footer

    func addGoToGlobalPosition(withAction action: @escaping () -> Void) {
        let globalPositionFooterViewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnHome",
            title: localized("generic_button_globalPosition"),
            action: action
        )
        self.footerItems.append(globalPositionFooterViewModel)
    }

    func addHelpUsToImprove(withAction action: @escaping () -> Void) {
        let helpToImproveFooterViewModel = OperativeSummaryStandardFooterItemViewModel(
            imageKey: "icnLike",
            title: localized("generic_button_improve"),
            action: action
        )
        self.footerItems.append(helpToImproveFooterViewModel)
    }

    func build() -> OperativeSummaryStandardViewModel {
        return OperativeSummaryStandardViewModel(
            header: OperativeSummaryStandardHeaderViewModel(image: "icnCheckOval",
                                                            title: localized("summe_title_perfect"),
                                                            description: localized("summary_title_anticipatedAmortization"),
                                                            extraInfo: nil),
            bodyItems: self.bodyItems,
            bodyActionItems: self.bodyActionItems,
            footerItems: self.footerItems
        )
    }
}
