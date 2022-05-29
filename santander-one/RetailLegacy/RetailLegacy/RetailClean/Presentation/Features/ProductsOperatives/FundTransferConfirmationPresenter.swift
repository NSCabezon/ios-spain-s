import Foundation

class FundTransferConfirmationPresenter: OperativeStepPresenter<FundTransferConfirmationViewController, DefaultMifidLauncherNavigator, FundTransferConfirmationPresenterProtocol> {
    override var screenId: String? {
        return TrackerPagePrivate.FundTransferConfirmation().page
    }
    
    var operative: MifidLauncherOperative? {
        return container?.operative as? MifidLauncherOperative
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")
        
        guard let container = container else {
            fatalError()
        }
        
        let fund: Fund = container.provideParameter()
        let fundDetail: FundDetail = container.provideParameter()
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        let account: Account? = container.provideParameterOptional()
        
        let fundSection = TableModelViewSection()
        let fundHeader = TitledTableModelViewHeader()
        fundHeader.title = stringLoader.getString("confirmation_item_funds")
        fundSection.setHeader(modelViewHeader: fundHeader)
        let fundItemOrigin = FundTransferConfirmationOriginDestinationViewModel(fund, originDestination: stringLoader.getString("confirmation_text_origin").text, dependencies)
        let fundItemDestination = FundTransferConfirmationOriginDestinationViewModel(fundTransferTransaction.destinationFund, originDestination: stringLoader.getString("confirmation_text_destination").text, dependencies)
        fundSection.items = [fundItemOrigin, fundItemDestination]
        
        let transferSection = TableModelViewSection()
        let transferHeader = TitledTableModelViewHeader()
        transferHeader.title = stringLoader.getString("foundOperation_text_transfer")
        transferSection.setHeader(modelViewHeader: transferHeader)
        
        switch fundTransferTransaction.fundTransferType! {
        case .total:
            let confirmationHeader = ConfirmationTableViewHeaderModel(stringLoader.getString("foundTransfer_radiobutton_total").text, dependencies)
            transferSection.items.append(confirmationHeader)
        case .partialAmount:
            let confirmationHeader = ConfirmationTableViewHeaderModel(fundTransferTransaction.amount?.getFormattedAmountUI(2) ?? "", dependencies)
            transferSection.items.append(confirmationHeader)
        case .partialShares:
            let amountToShow = fundTransferTransaction.shares?.getFormattedValue(5)
            
            if let amountNotNil = fundTransferTransaction.shares {
                let headerString = (amountToShow ?? "") + " " + stringLoader.getQuantityString("foundOperation_text_numberParticipations", amountNotNil.doubleValue, []).text
                
                let confirmationHeader = ConfirmationTableViewHeaderModel(headerString, dependencies)
                transferSection.items.append(confirmationHeader)
            }
        }
        
        let description = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_description"),
                                                         fundDetail.getDescription() ?? "",
                                                         false,
                                                         dependencies)
        transferSection.items.append(description)
        let associatedAccount = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_associatedAccount"),
                                                               account?.getAliasAndInfo() ?? IBAN.create(fromText: fundTransferTransaction.associatedAccount).getAliasAndInfo(withCustomAlias: stringLoader.getString("generic_summary_associatedAccount").text),
                                                               false,
                                                               dependencies)
        transferSection.items.append(associatedAccount)
        let destinationContract = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_destinationFund"),
                                                                 fundTransferTransaction.destinationFund.getAliasAndInfo(),
                                                                 false,
                                                                 dependencies)
        transferSection.items.append(destinationContract)
        var dateString = ""
        if let date = fundTransferTransaction.valueDate {
            dateString = dependencies.timeManager.toString(date: date, outputFormat: TimeFormat.d_MMM_yyyy) ?? ""
        }
        let date = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_dateTransfer"),
                                                   dateString,
                                                  true,
                                                  dependencies)
        transferSection.items.append(date)
        
        view.sections = [fundSection, transferSection]
    }
}

extension FundTransferConfirmationPresenter: FundTransferConfirmationPresenterProtocol {
    func confirmButtonTouched() {
       
        guard let container = self.container as? OperativeContainer else {
            return
        }
        operative?.mifidLaunched(from: self)
        navigator.launchMifid2(withContainer: container, forOperative: .fundsTransfer, delegate: self, stringLoader: stringLoader)
    }
}

extension FundTransferConfirmationPresenter: MifidLauncherPresenterProtocol {
    func performValidate(for mifidContainer: MifidContainerProtocol, onSuccess: @escaping () -> Void) {
        
        guard let container = container else {
            return
        }
        
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        let fund: Fund = container.provideParameter()
        
        switch fundTransferTransaction.fundTransferType! {
        case .total:
            let caseInput = ValidateTotalFundTransferUseCaseInput(originFund: fund, destinationFund: fundTransferTransaction.destinationFund)
            UseCaseWrapper(with: useCaseProvider.validateTotalFundTransferUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
                
                guard let strongSelf = self else { return }
                let fundTransfer = FundTransfer.create(response.fundTransfer)
                strongSelf.onSuccessUseCaseCall(operativeContainer: container, mifidContainer: mifidContainer, fundTransfer: fundTransfer)
                onSuccess()
            }, onGenericErrorType: { [weak self] (errorType) in
                guard let strongSelf = self else { return }
                mifidContainer.hideCommonLoading {
                    switch errorType {
                    case .error(let error):
                        strongSelf.showError(keyDesc: error?.getErrorDesc())
                    case .networkUnavailable:
                        strongSelf.showError(keyDesc: "generic_error_needInternetConnection")
                    case .generic, .intern, .unauthorized:
                        strongSelf.showError(keyDesc: nil)
                    }
                    
                }
            })
            
        case .partialAmount:
            guard let auxAmount = fundTransferTransaction.amount else {
                mifidContainer.hideCommonLoading { [weak self] in
                    self?.showError(keyDesc: nil)
                }
                return
            }
            
            let caseInput = ValidatePartialAmountFundTransferUseCaseInput(originFund: fund, destinationFund: fundTransferTransaction.destinationFund, amount: auxAmount)
            UseCaseWrapper(with: useCaseProvider.validatePartialAmountFundTransferUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
                
                guard let strongSelf = self else { return }
                let fundTransfer = FundTransfer.create(response.fundTransfer)
                strongSelf.onSuccessUseCaseCall(operativeContainer: container, mifidContainer: mifidContainer, fundTransfer: fundTransfer)
                onSuccess()
            }, onGenericErrorType: { [weak self] (errorType) in
                guard let strongSelf = self else { return }
                mifidContainer.hideCommonLoading {
                    switch errorType {
                    case .error(let error):
                        strongSelf.showError(keyDesc: error?.getErrorDesc())
                    case .networkUnavailable:
                        strongSelf.showError(keyDesc: "generic_error_needInternetConnection")
                    case .generic, .intern, .unauthorized:
                        strongSelf.showError(keyDesc: nil)
                    }
                }
            })
            
        case .partialShares:
            guard let auxShares = fundTransferTransaction.shares else {
                mifidContainer.hideCommonLoading { [weak self] in
                    self?.showError(keyDesc: nil)
                }
                return
            }
            
            let caseInput = ValidatePartialSharesFundTransferUseCaseInput(originFund: fund, destinationFund: fundTransferTransaction.destinationFund, shares: auxShares)
            UseCaseWrapper(with: useCaseProvider.validatePartialSharesFundTransferUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
                
                guard let strongSelf = self else { return }
                let fundTransfer = FundTransfer.create(response.fundTransfer)
                strongSelf.onSuccessUseCaseCall(operativeContainer: container, mifidContainer: mifidContainer, fundTransfer: fundTransfer)
                onSuccess()
            }, onGenericErrorType: { [weak self] (errorType) in
                guard let strongSelf = self else { return }
                mifidContainer.hideCommonLoading {
                    switch errorType {
                    case .error(let error):
                        strongSelf.showError(keyDesc: error?.getErrorDesc())
                    case .networkUnavailable:
                        strongSelf.showError(keyDesc: "generic_error_needInternetConnection")
                    case .generic, .intern, .unauthorized:
                        strongSelf.showError(keyDesc: nil)
                    }
                }
            })
        }
    }
    
    private func onSuccessUseCaseCall(operativeContainer: OperativeContainerProtocol, mifidContainer: MifidContainerProtocol, fundTransfer: FundTransfer) {
        guard let signature = fundTransfer.signature else {
            mifidContainer.hideCommonLoading {
                self.showError(keyDesc: nil)
            }
            return
        }
        operativeContainer.saveParameter(parameter: fundTransfer)
        operativeContainer.saveParameter(parameter: signature)
    }
}
