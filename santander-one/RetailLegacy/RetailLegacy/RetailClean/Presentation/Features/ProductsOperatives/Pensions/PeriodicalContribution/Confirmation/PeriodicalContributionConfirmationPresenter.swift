class PeriodicalContributionConfirmationPresenter: OperativeStepPresenter<PeriodicalContributionConfirmationViewController, VoidNavigator, PeriodicalContributionConfirmationPresenterProtocol> {
    override var screenId: String? {
        return TrackerPagePrivate.PensionPeriodicalContributionConfirmation().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")
        
        guard let container = container as? OperativeContainer else {
            fatalError()
        }
        
        let pension: Pension = container.provideParameter()
        let amount: Amount = container.provideParameter()
        let contributionConfiguration: ContributionConfiguration = container.provideParameter()
        
        let pensionSection = TableModelViewSection()
        
        let pensionHeader = TitledTableModelViewHeader()
        pensionHeader.title = stringLoader.getString("confirmation_item_plan")
        
        pensionSection.setHeader(modelViewHeader: pensionHeader)
        
        let pensionItem = GenericProductConfirmationViewModel(pension, dependencies)
        pensionSection.items = [pensionItem]
        
        let contributionConfigurationSection = TableModelViewSection()
        
        let contributionConfigurationHeader = TitledTableModelViewHeader()
        contributionConfigurationHeader.title = stringLoader.getString("confirmation_item_periodicContribution")
        
        contributionConfigurationSection.setHeader(modelViewHeader: contributionConfigurationHeader)
        
        let amountItem = ConfirmationTableViewHeaderModel(amount.getFormattedAmountUI(2), dependencies)
        contributionConfigurationSection.items.append(amountItem)
        
        let periodicityItem = ConfirmationTableViewItemModel(stringLoader.getString("periodicContribution_label_periodicity"),
                                                         contributionConfiguration.periodicity.localizedText(stringLoader: stringLoader).text,
                                                         false,
                                                         dependencies)
        contributionConfigurationSection.items.append(periodicityItem)
        
        let startDateItem = ConfirmationTableViewItemModel(stringLoader.getString("periodicContribution_label_startDate"),
                                                               dependencies.timeManager.toString(date: contributionConfiguration.startDate, outputFormat: .d_MMM_yyyy) ?? "",
                                                               false,
                                                               dependencies)
        contributionConfigurationSection.items.append(startDateItem)
        
        let destinationContract = ConfirmationTableViewItemModel(stringLoader.getString("periodicContribution_label_revaluation"),
                                                                 contributionConfiguration.revaluation.localizedText(stringLoader: stringLoader).text,
                                                                 true,
                                                                 dependencies)
        contributionConfigurationSection.items.append(destinationContract)
        
        view.sections = [pensionSection, contributionConfigurationSection]
    }
}

extension PeriodicalContributionConfirmationPresenter: PeriodicalContributionConfirmationPresenterProtocol {
    func confirmButtonTouched() {
        
        guard let container = container as? OperativeContainer else {
            fatalError()
        }
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        
        UseCaseWrapper(with: useCaseProvider.validatePeriodicalContributionUseCase(), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            guard let strongSelf = self else { return }
            strongSelf.hideLoading(completion: {
                let signatureToken = response.signatureWithToken
                container.saveParameter(parameter: signatureToken)
                container.stepFinished(presenter: strongSelf)
            })
        }, onError: { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.hideLoading(completion: {
                strongSelf.showError(keyDesc: error?.getErrorDesc(), phone: nil)
            })
        })
    }
}
