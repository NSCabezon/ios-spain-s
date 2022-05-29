import CoreFoundationLib
import UIKit

class FundTransferTypeSelectionPresenter: OperativeStepPresenter<FundTransferTypeSelectionViewController, VoidNavigator, FundTransferTypeSelectionPresenterProtocol> {

    private lazy var radio: RadioTable = RadioTable(delegate: self)
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_foundTransfer")
        infoObtained()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.FundTransferType().page
    }
    
    private func infoObtained() {
        
        guard let container = container else {
            fatalError()
        }
        
        let fund: Fund = container.provideParameter()
        let fundDetail: FundDetail = container.provideParameter()
        
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        view.continueButton.onTouchAction = { [weak self] _ in
            self?.onContinueButtonClicked()
        }
        
        let sectionHeader = TableModelViewSection()
        let headerViewModel = GenericHeaderOneLineViewModel(leftTitle: .plain(text: fund.getAlias()?.camelCasedString),
                                                            rightTitle: .plain(text: fundDetail.getAmountUI()))
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderOneLineView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let sectionContent = TableModelViewSection()
        let totalModel = FundTransferTypeSelectionModelView(type: .total, radio: radio, privateComponent: dependencies)
        let partialAmount = FundTransferTypeSelectionModelView(type: .partialAmount, radio: radio, privateComponent: dependencies)
        let partialShares = FundTransferTypeSelectionModelView(type: .partialShares, radio: radio, privateComponent: dependencies)
        let labelModel = SubscriptionOperativeLabelTableModelView(dependencies: dependencies)
        labelModel.value = stringLoader.getString("generic_text_infoHours").text
        sectionContent.items += [totalModel, partialAmount, partialShares]
        view.sections = [sectionHeader, sectionContent]
    }
    
    private func getModelViewSelected () -> FundTransferTypeSelectionModelView? {
        guard let index = radio.indexSelected(), let section = getSection(section: index.section), let modelView = getModelView(section: section, row: index.row) else {
            return nil
        }
        return modelView
    }
    
    private func getTextForModelView(modelView: FundTransferTypeSelectionModelView) -> String? {
        guard let text = modelView.field?.text, !text.isEmpty else {
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
    
    private func getModelView (section: TableModelViewSection, row: Int) -> FundTransferTypeSelectionModelView? {
        guard section.items.count > row else {
            return nil
        }
        return section.items[row] as? FundTransferTypeSelectionModelView
    }
}

// MARK: - FundSubscriptionPresenterProtocol

extension FundTransferTypeSelectionPresenter: FundTransferTypeSelectionPresenterProtocol {
    
    func selected(index: IndexPath) {
        radio.didSelectCellComponent(indexPath: index)
    }
}

// MARK: - FundSubscriptionPresenterProtocol

extension FundTransferTypeSelectionPresenter: RadioTableDelegate {
    var tableComponent: UITableView {
        return view.tableView
    }
}

// MARK: - RadioTableActionDelegate

extension FundTransferTypeSelectionPresenter: RadioTableActionDelegate {
    func auxiliaryButtonAction(tag: Int, completion: (_ action: RadioTableAuxiliaryAction) -> Void) {
        completion(.none)
    }
    
    func onContinueButtonClicked() {
        guard let container = self.container as? OperativeContainer else {
            return
        }
        
        let fund: Fund = container.provideParameter()
        
        guard let modelView = self.getModelViewSelected() else {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "generic_error_radiobuttonNull", phone: nil, completion: nil)
            return
        }
        
        switch modelView.type {
        case .total:
            showOperativeLoading(titleToUse: nil, subtitleToUse: "loading_label_moment", source: nil)
            performTotalUseCase(originFund: fund, container: container)
        case .partialAmount:
            if let amountError = getAmountParserError(modelView: modelView) {
                showError(keyTitle: "generic_alert_title_errorData", keyDesc: amountError)
                return
            }
            
            let decimalAmount = Decimal(string: self.getTextForModelView(modelView: modelView)!.replace(".", "").replace(",", "."))!
            showOperativeLoading(titleToUse: nil, subtitleToUse: "loading_label_moment", source: nil)
            performAmountUseCase(originFund: fund, container: container, decimalValue: decimalAmount)
        case .partialShares:
            if let sharesError = getSharesParserError(modelView: modelView) {
                showError(keyTitle: "generic_alert_title_errorData", keyDesc: sharesError)
                return
            }
            
            let shares = Decimal(string: self.getTextForModelView(modelView: modelView)!.replace(".", "").replace(",", "."))!
            showOperativeLoading(titleToUse: nil, subtitleToUse: "loading_label_moment", source: nil)
            performSharesUseCase(originFund: fund, container: container, decimalValue: shares)
        }
    }
    
    func getAmountParserError(modelView: FundTransferTypeSelectionModelView) -> String? {
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
    
    func getSharesParserError(modelView: FundTransferTypeSelectionModelView) -> String? {
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
    
    func performTotalUseCase(originFund: Fund, container: OperativeContainer) {
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        let caseInput = ValidateTotalFundTransferUseCaseInput(originFund: originFund, destinationFund: fundTransferTransaction.destinationFund)
        UseCaseWrapper(with: useCaseProvider.validateTotalFundTransferUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
        
            guard let strongSelf = self else { return }
            fundTransferTransaction.fundTransferType = FundTransferType.total
            let fundTransfer = FundTransfer(dto: response.fundTransfer)
            
            fundTransferTransaction.associatedAccount = fundTransfer.ibanPapel
            fundTransferTransaction.valueDate = fundTransfer.valueDate
            container.saveParameter(parameter: fundTransferTransaction)
            if let signature = response.fundTransfer.signature, let account = response.account {
                container.saveParameter(parameter: Signature(dto: signature))
                container.saveParameter(parameter: account)
            }
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
    
    func performAmountUseCase(originFund: Fund, container: OperativeContainer, decimalValue: Decimal) {
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        let auxAmount = Amount.create(value: decimalValue, currency: Currency.create(withType: CoreCurrencyDefault.default))

        let caseInput = ValidatePartialAmountFundTransferUseCaseInput(originFund: originFund, destinationFund: fundTransferTransaction.destinationFund, amount: auxAmount)
        UseCaseWrapper(with: useCaseProvider.validatePartialAmountFundTransferUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
        
            guard let strongSelf = self else { return }
            fundTransferTransaction.fundTransferType = FundTransferType.partialAmount
            fundTransferTransaction.amount = auxAmount
            let fundTransfer = FundTransfer(dto: response.fundTransfer)
            
            fundTransferTransaction.associatedAccount = fundTransfer.ibanPapel
            fundTransferTransaction.valueDate = fundTransfer.valueDate
            container.saveParameter(parameter: fundTransferTransaction)
            if let signature = response.fundTransfer.signature, let account = response.account {
                container.saveParameter(parameter: Signature(dto: signature))
                container.saveParameter(parameter: account)
            }
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
    
    func performSharesUseCase(originFund: Fund, container: OperativeContainer, decimalValue: Decimal) {
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        let caseInput = ValidatePartialSharesFundTransferUseCaseInput(originFund: originFund, destinationFund: fundTransferTransaction.destinationFund, shares: decimalValue)
        UseCaseWrapper(with: useCaseProvider.validatePartialSharesFundTransferUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            
            guard let strongSelf = self else { return }
            fundTransferTransaction.fundTransferType = FundTransferType.partialShares
            fundTransferTransaction.shares = decimalValue
            
            let fundTransfer = FundTransfer(dto: response.fundTransfer)
            
            fundTransferTransaction.associatedAccount = fundTransfer.ibanPapel
            fundTransferTransaction.valueDate = fundTransfer.valueDate
            container.saveParameter(parameter: fundTransferTransaction)
            if let signature = response.fundTransfer.signature, let account = response.account {
                container.saveParameter(parameter: Signature(dto: signature))
                container.saveParameter(parameter: account)
            }
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
