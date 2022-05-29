import Foundation

class ExtraordinaryContributionConfirmationPresenter: OperativeStepPresenter<ExtraordinaryContributionConfirmationViewController, DefaultMifidLauncherNavigator, ExtraordinaryContributionConfirmationPresenterProtocol> {
    override var screenId: String? {
        return TrackerPagePrivate.PensionExtraordinaryContributionConfirmation().page
    }
    
    var operative: MifidLauncherOperative? {
        return container?.operative as? MifidLauncherOperative
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")
        
        let operativeData: ExtraContributionPensionOperativeData = containerParameter()
        let extraContributionPension = operativeData.extraContributionPension
        guard
            let pension = extraContributionPension?.originPension,
            let amount = extraContributionPension?.amount,
            let pensionInfo = extraContributionPension?.pensionInfoOperation else {
                return
        }
        
        let associatedAccount = extraContributionPension?.account
        
        let pensionSection = TableModelViewSection()
        
        let pensionHeader = TitledTableModelViewHeader()
        pensionHeader.title = stringLoader.getString("confirmation_item_plan")
        
        pensionSection.setHeader(modelViewHeader: pensionHeader)
        
        let pensionItem = GenericProductConfirmationViewModel(pension, dependencies)
        pensionSection.items = [pensionItem]
        
        let contributionConfigurationSection = TableModelViewSection()
        
        let contributionConfigurationHeader = TitledTableModelViewHeader()
        contributionConfigurationHeader.title = stringLoader.getString("confirmation_item_extraContribution")
        
        contributionConfigurationSection.setHeader(modelViewHeader: contributionConfigurationHeader)
        
        let amountItem = ConfirmationTableViewHeaderModel(amount.getFormattedAmountUI(2), dependencies)
        contributionConfigurationSection.items.append(amountItem)
        
        //Descripcion
        let descriptionItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_description"),
                                                             pensionInfo.description ?? "",
                                                             false,
                                                             dependencies)
        contributionConfigurationSection.items.append(descriptionItem)
        
        //Cuenta asociada
        let associatedAccountItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_associatedAccount"),
                                                                  associatedAccount?.getAliasAndInfo() ?? pensionInfo.associatedAccountIban.getAliasAndInfo(withCustomAlias: dependencies.stringLoader.getString("generic_summary_associatedAccount").text),
                                                                  false,
                                                                  dependencies)
        contributionConfigurationSection.items.append(associatedAccountItem)
        
        let dateItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_date"),
                                                           dependencies.timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy) ?? "",
                                                           true,
                                                           dependencies)
        contributionConfigurationSection.items.append(dateItem)
                
        view.sections = [pensionSection, contributionConfigurationSection]
    }
}

extension ExtraordinaryContributionConfirmationPresenter: ExtraordinaryContributionConfirmationPresenterProtocol {
    func confirmButtonTouched() {
        guard let container = container as? OperativeContainer else {
            fatalError()
        }
        operative?.mifidLaunched(from: self)
        navigator.launchMifid2(withContainer: container, forOperative: .pensionsExtraordinaryContribution, delegate: self, stringLoader: stringLoader)
    }
}

extension ExtraordinaryContributionConfirmationPresenter: MifidLauncherPresenterProtocol {
    func performValidate(for mifidContainer: MifidContainerProtocol, onSuccess: @escaping () -> Void) {
        UseCaseWrapper(with: useCaseProvider.validateExtraordinaryContributionUseCase(), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            guard let strongSelf = self else { return }
            let signature = response.signatureWithToken
            strongSelf.container?.saveParameter(parameter: signature)
            onSuccess()
        }, onGenericErrorType: { [weak self] errorType in
            mifidContainer.hideCommonLoading { [weak self] in
                guard let strongSelf = self else { return }
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
