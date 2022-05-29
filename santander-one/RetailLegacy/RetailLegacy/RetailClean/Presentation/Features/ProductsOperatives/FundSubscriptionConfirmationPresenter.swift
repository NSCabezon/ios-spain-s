import Foundation

class FundSubscriptionConfirmationPresenter: OperativeStepPresenter<FundSubscriptionConfirmationViewController, DefaultMifidLauncherNavigator, FundSubscriptionConfirmationPresenterProtocol> {
    
    var operative: MifidLauncherOperative? {
        return container?.operative as? MifidLauncherOperative
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")
        guard let container = container as? OperativeContainer else {
            fatalError()
        }
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fund = operativeData.productSelected, let fundDetail = operativeData.fundDetail, let fundSubscriptionTransaction = operativeData.fundSubscriptionTransaction else {
            return
        }
        let fundSubscriptionType = fundSubscriptionTransaction.fundSubscriptionType

        let account = operativeData.account
        
        let loanSection = TableModelViewSection()
        
        let loanHeader = TitledTableModelViewHeader()
        loanHeader.title = stringLoader.getString("foundOperation_text_found")
        
        loanSection.setHeader(modelViewHeader: loanHeader)
        
        let loanItem = FundSubscriptionConfirmationFundViewModel(fund, dependencies)
        loanSection.items = [loanItem]
        
        let accountSection = TableModelViewSection()
        
        let accountHeader = TitledTableModelViewHeader()
        accountHeader.title = stringLoader.getString("foundOperation_text_subscription")
        
        accountSection.setHeader(modelViewHeader: accountHeader)
        
        //HASTA AQUI 1º CELDA Y HEADERS
        switch fundSubscriptionType {
        case .amount:
            let confirmationHeader = ConfirmationTableViewHeaderModel(fundSubscriptionTransaction.amount?.getFormattedAmountUI(2) ?? "", dependencies)
            accountSection.items.append(confirmationHeader)
        case .participation:
            let amountToShow = fundSubscriptionTransaction.shares?.getFormattedValue(5)
            
            if let amountNotNil = fundSubscriptionTransaction.shares {
                let headerString = (amountToShow ?? "") + " " + stringLoader.getQuantityString("foundOperation_text_numberParticipations", amountNotNil.doubleValue, []).text
                
                let confirmationHeader = ConfirmationTableViewHeaderModel(headerString, dependencies)
                accountSection.items.append(confirmationHeader)
            }
        }
        
        let description = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_description"),
                                                         fundDetail.getDescription() ?? "",
                                                         false,
                                                         dependencies)
        accountSection.items.append(description)
        
        let destinationFund = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_destinationFund"),
                                                                 fund.getAliasAndInfo(),
                                                                 false,
                                                                 dependencies)
        accountSection.items.append(destinationFund)
        
        let associatedAccount = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_associatedAccount"),
                                                               account?.getAliasAndInfo() ?? IBAN.create(fromText: fundSubscriptionTransaction.associatedAccount).getAliasAndInfo(withCustomAlias: stringLoader.getString("generic_summary_associatedAccount").text),
                                                               false,
                                                               dependencies)
        accountSection.items.append(associatedAccount)
        
        let date = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_date"),
                                                  dependencies.timeManager.toString(date: Date(), outputFormat: TimeFormat.d_MMM_yyyy) ?? "",
                                                  true,
                                                  dependencies)
        accountSection.items.append(date)
        
        view.sections = [loanSection, accountSection]
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.FundSubscriptionConfirmation().page
    }
}

extension FundSubscriptionConfirmationPresenter: FundSubscriptionConfirmationPresenterProtocol {
    func confirmButtonTouched() {

        guard let container = container as? OperativeContainer else {
            fatalError()
        }
        operative?.mifidLaunched(from: self)
        navigator.launchMifid2(withContainer: container, forOperative: .fundsSubscription, delegate: self, stringLoader: stringLoader)
    }
}

extension FundSubscriptionConfirmationPresenter: MifidLauncherPresenterProtocol {
    func performValidate(for mifidContainer: MifidContainerProtocol, onSuccess: @escaping () -> Void) {
        guard let container = container as? OperativeContainer else {
            fatalError()
        }
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fund = operativeData.productSelected, let fundSubscriptionTransaction = operativeData.fundSubscriptionTransaction else {
            return
        }
        
        switch fundSubscriptionTransaction.fundSubscriptionType {
        case .amount:
            guard let auxAmount = fundSubscriptionTransaction.amount else {
                mifidContainer.hideCommonLoading { [weak self] in
                    self?.showError(keyDesc: nil)
                }
                return
            }
            
            let caseInput = ValidateFundSubscriptionAmountUseCaseInput(fund: fund, amount: auxAmount)
            UseCaseWrapper(with: useCaseProvider.validateFundSubscriptionAmountUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
                
                guard let strongSelf = self else { return }
                let fundSubscription = response.fundSubscription
                strongSelf.onSuccessUseCaseCall(operativeContainer: container, mifidContainer: mifidContainer, fundSubscription: fundSubscription)
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
            
        case .participation:
            guard let auxShares = fundSubscriptionTransaction.shares else {
                
                mifidContainer.hideCommonLoading { [weak self] in
                    self?.showError(keyDesc: nil)
                }
                return
            }
            
            let caseInput = ValidateFundSubscriptionSharesUseCaseInput(fund: fund, sharesNumber: auxShares)
            UseCaseWrapper(with: useCaseProvider.validateFundSubscriptionSharesUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
                
                guard let strongSelf = self else { return }
                
                let fundSubscription = response.fundSubscription
                strongSelf.onSuccessUseCaseCall(operativeContainer: container, mifidContainer: mifidContainer, fundSubscription: fundSubscription)
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
    
    private func onSuccessUseCaseCall(operativeContainer: OperativeContainerProtocol, mifidContainer: MifidContainerProtocol, fundSubscription: FundSubscription) {
        
        guard let signature = fundSubscription.signature else {
            mifidContainer.hideCommonLoading { [weak self] in
                self?.showError(keyDesc: nil)
            }
            return
        }
        let operativeData: FundSubscriptionOperativeData = operativeContainer.provideParameter()
        operativeData.fundSubscription = fundSubscription
        operativeContainer.saveParameter(parameter: operativeData)
        operativeContainer.saveParameter(parameter: signature)
    }
}
