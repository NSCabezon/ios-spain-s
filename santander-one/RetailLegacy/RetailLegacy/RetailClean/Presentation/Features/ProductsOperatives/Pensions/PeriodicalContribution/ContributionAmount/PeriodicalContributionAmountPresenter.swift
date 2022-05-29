import Foundation

class PeriodicalContributionAmountPresenter: OperativeStepPresenter<PeriodicalContributionAmountViewController, VoidNavigator, PeriodicalContributionAmountPresenterProtocol> {
    private var pension: Pension?
    override var screenId: String? {
        return TrackerPagePrivate.PensionPeriodicalContribution().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        guard let container = container else {
            return
        }
        pension = container.provideParameter()
        
        infoObtained()
    }
    
    private func infoObtained() {
        view.styledTitle = stringLoader.getString("toolbar_title_periodicContribution")
        view.confirmButtonTitle = stringLoader.getString("generic_button_continue")
        
        let sectionHeader = TableModelViewSection()
        let headerViewModel = GenericHeaderOneLineViewModel(leftTitle: .plain(text: pension?.getAlias()),
                                                            rightTitle: .plain(text: pension?.getAmountUI()))
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderOneLineView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let sectionContent = TableModelViewSection()
        
        let amountLabelModel = AmountInputViewModel(inputIdentifier: "amount", titleText: stringLoader.getString("periodicContribution_text_amount"), textFormatMode: FormattedTextField.FormatMode.defaultCurrency(12, 2), dependencies: dependencies)
        
        sectionContent.items += [amountLabelModel]
        view.sections = [sectionHeader, sectionContent]
    }
    
    private func viewModelForIdentifier(identifier: String) -> String? {
        let sections = view.itemsSectionContent().compactMap({$0 as? InputIdentificable}).filter({$0?.inputIdentifier == identifier}).compactMap({$0})
        return sections.first?.dataEntered
    }
}

// MARK: - PeriodicalContributionAmountPresenterProtocol

extension PeriodicalContributionAmountPresenter: PeriodicalContributionAmountPresenterProtocol {
    func confirmButtonTouched() {
        guard let container = self.container, let pension = pension else {
            return
        }
        
        guard let contributionAmount = viewModelForIdentifier(identifier: "amount"), !contributionAmount.isEmpty else {
            self.showError(keyDesc: "generic_alert_text_errorAmount")
            return
        }
        
        switch Decimal.getAmountParserResult(value: contributionAmount) {
        case .success(let value):
            guard let amountReference = pension.getAmount(), let amount = Amount.createWith(value: value, amount: amountReference) else {
                return
            }
            container.saveParameter(parameter: amount)
            container.stepFinished(presenter: self)
        case .error(let error):
            let key = Decimal.defaultErrorDescriptionKey(forAmountError: error)
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: key)
        }
    }
}
