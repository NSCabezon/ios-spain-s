import CoreFoundationLib
import UIKit

enum FundSubscriptionType {
    case amount
    case participation
}

class FundSubscriptionPresenter: OperativeStepPresenter<FundSubscriptionViewController, VoidNavigator, FundSubscriptionPresenterProtocol> {

    private lazy var radio: RadioTable = RadioTable(delegate: self)
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_foundSubscription")
        infoObtained()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.FundSubscription().page
    }
    
    private func infoObtained() {
        guard let container = container else {
            return
        }
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fund = operativeData.productSelected, let fundDetail = operativeData.fundDetail else {
            return
        }
        
        let sectionHeader = TableModelViewSection()
        let headerViewModel = GenericHeaderOneLineViewModel(leftTitle: .plain(text: fund.getAlias()?.camelCasedString),
                                                            rightTitle: .plain(text: fundDetail.getAmountUI()))
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderOneLineView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        view.continueButton.onTouchAction = { [weak self] _ in
            self?.onContinueButtonClicked()
        }
        let sectionContent = TableModelViewSection()
        let amountModel = FundSubscriptionModelView(type: .amount, radio: radio, privateComponent: dependencies)
        let participationModel = FundSubscriptionModelView(type: .participation, radio: radio, privateComponent: dependencies)
        let labelModel = SubscriptionOperativeLabelTableModelView(dependencies: dependencies)
        labelModel.value = stringLoader.getString("generic_text_infoHours").text
        sectionContent.items += [amountModel, participationModel, labelModel]
        view.sections = [sectionHeader, sectionContent]
    }
    
    private func getModelViewSelected () -> FundSubscriptionModelView? {
        guard let index = radio.indexSelected(), let section = getSection(section: index.section), let modelView = getModelView(section: section, row: index.row) else {
            return nil
        }
        return modelView
    }
    
    private func getTextForModelView(modelView: FundSubscriptionModelView) -> String? {
        guard let text = modelView.field.text, !text.isEmpty else {
            return nil
        }
        return text
    }
    
    private func getSection (section: Int) -> TableModelViewSection? {
        guard view.sections.count > section else {
            return nil
        }
        return view.sections[section]
    }
    
    private func getModelView (section: TableModelViewSection, row: Int) -> FundSubscriptionModelView? {
        guard section.items.count > row else {
            return nil
        }
        return section.items[row] as? FundSubscriptionModelView
    }
}

class FundSubscriptionTransaction: OperativeParameter {
    
    var fundSubscriptionType: FundSubscriptionType
    var amount: Amount?
    var shares: Decimal?
    var associatedAccount: String
    
    public init(fundSubscriptionType: FundSubscriptionType, amount: Amount?, shares: Decimal?, associatedAccount: String) {
        self.fundSubscriptionType = fundSubscriptionType
        self.amount = amount
        self.shares = shares
        self.associatedAccount = associatedAccount
    }
}

// MARK: - FundSubscriptionPresenterProtocol

extension FundSubscriptionPresenter: FundSubscriptionPresenterProtocol {
    
    func selected(index: IndexPath) {
        radio.didSelectCellComponent(indexPath: index)
    }
}

// MARK: - FundSubscriptionPresenterProtocol

extension FundSubscriptionPresenter: RadioTableDelegate {
    var tableComponent: UITableView {
        return view.tableView
    }
}

// MARK: - RadioTableActionDelegate

extension FundSubscriptionPresenter: RadioTableActionDelegate {
    func auxiliaryButtonAction(tag: Int, completion: (_ action: RadioTableAuxiliaryAction) -> Void) {
        completion(.none)
    }
    
    func onContinueButtonClicked() {
        guard let container = self.container as? OperativeContainer else {
            return
        }
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fund = operativeData.productSelected else {
            return
        }
        
        guard let modelView = self.getModelViewSelected() else {
            self.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "generic_error_radiobuttonNull")
            return
        }
        
        switch modelView.type {
        case .amount:
            if let amountError = getAmountParserError(modelView: modelView) {
                showError(keyTitle: "generic_alert_title_errorData", keyDesc: amountError)
                return
            }
            
            let decimalAmount = Decimal(string: self.getTextForModelView(modelView: modelView)!.replace(".", "").replace(",", "."))!
            showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
            performAmountUseCase(fund: fund, container: container, decimalValue: decimalAmount)
        case .participation:
            if let sharesError = getSharesParserError(modelView: modelView) {
                showError(keyTitle: "generic_alert_title_errorData", keyDesc: sharesError)
                return
            }
            
            let shares = Decimal(string: self.getTextForModelView(modelView: modelView)!.replace(".", "").replace(",", "."))!
            showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
            performSharesUseCase(fund: fund, container: container, decimalValue: shares)
        }
        
        container.stepFinished(presenter: self)
    }
    
    func getAmountParserError(modelView: FundSubscriptionModelView) -> String? {
        guard let text = self.getTextForModelView(modelView: modelView) else {
            return "generic_alert_text_errorAmount"
        }
        
        guard let decimal = Decimal(string: text.replace(".", "").replace(",", ".")) else {
            return "generic_alert_text_errorData_numberAmount"
        }
        
        if decimal == Decimal(string: "0") {
            return "generic_alert_text_errorData_amount"
        }
        
        return nil
    }
    
    func getSharesParserError(modelView: FundSubscriptionModelView) -> String? {
        guard let text = self.getTextForModelView(modelView: modelView) else {
            return "generic_alert_text_errorParticipations"
        }
        
        guard let shares = Decimal(string: text.replace(".", "").replace(",", ".")) else {
            return "generic_alert_text_errorData_numberParticipations"
        }
        
        if shares == Decimal(string: "0") {
            return "generic_alert_text_errorData_participations"
        }
        
        return nil
    }
    
    func performAmountUseCase(fund: Fund, container: OperativeContainerProtocol, decimalValue: Decimal) {
        let auxAmount = Amount.create(value: decimalValue, currency: Currency.create(withType: CoreCurrencyDefault.default))
        let caseInput = ValidateFundSubscriptionAmountUseCaseInput(fund: fund, amount: auxAmount)
        UseCaseWrapper(with: useCaseProvider.validateFundSubscriptionAmountUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            guard let strongSelf = self else { return }
            let operativeData: FundSubscriptionOperativeData = strongSelf.containerParameter()
            operativeData.amount = auxAmount
            operativeData.productSelected = fund
            let fundSubscriptionTransaction = FundSubscriptionTransaction(fundSubscriptionType: .amount, amount: auxAmount, shares: nil, associatedAccount: response.fundSubscription.ccc)
            operativeData.fundSubscriptionTransaction = fundSubscriptionTransaction
            if let account = response.account {
                operativeData.account = account
            }
            strongSelf.container?.saveParameter(parameter: operativeData)
            strongSelf.hideLoading(completion: {
                strongSelf.container?.stepFinished(presenter: strongSelf)
            })
        }, onError: { [weak self] (error) in
            
            guard let strongSelf = self else { return }
            strongSelf.hideLoading(completion: {
                strongSelf.showError(keyDesc: error?.getErrorDesc())
            })
        })
    }
    
    func performSharesUseCase(fund: Fund, container: OperativeContainerProtocol, decimalValue: Decimal) {
        let caseInput = ValidateFundSubscriptionSharesUseCaseInput(fund: fund, sharesNumber: decimalValue)
        UseCaseWrapper(with: useCaseProvider.validateFundSubscriptionSharesUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            guard let strongSelf = self else { return }
            let operativeData: FundSubscriptionOperativeData = strongSelf.containerParameter()
            operativeData.shares = decimalValue
            operativeData.productSelected = fund
            let fundSubscriptionTransaction = FundSubscriptionTransaction(fundSubscriptionType: .participation, amount: nil, shares: decimalValue, associatedAccount: response.fundSubscription.ccc)
            operativeData.fundSubscriptionTransaction = fundSubscriptionTransaction
            if let account = response.account {
                operativeData.account = account
            }
            strongSelf.container?.saveParameter(parameter: operativeData)
            strongSelf.hideLoading(completion: {
                strongSelf.container?.stepFinished(presenter: strongSelf)
            })
        }, onError: { [weak self] (error) in
            guard let strongSelf = self else { return }
            strongSelf.hideLoading(completion: {
                strongSelf.showError(keyDesc: error?.getErrorDesc())
            })
        })
    }
}
