import Foundation

class ExtraordinaryContributionAmountPresenter: OperativeStepPresenter<ExtraordinaryContributionAmountViewController, VoidNavigator, ExtraordinaryContributionAmountPresenterProtocol> {
    override var screenId: String? {
        return TrackerPagePrivate.PensionExtraordinaryContribution().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        infoObtained()
    }
    
    private func infoObtained() {
        view.styledTitle = stringLoader.getString("toolbar_title_extraContribution")
        view.confirmButtonTitle = stringLoader.getString("generic_button_continue")
        
        let operativeData: ExtraContributionPensionOperativeData = containerParameter()
        let pension = operativeData.productSelected
        
        let sectionHeader = TableModelViewSection()
        let headerViewModel = GenericHeaderOneLineViewModel(leftTitle: .plain(text: pension?.getAliasUpperCase()),
                                                            rightTitle: .plain(text: pension?.getAmountUI()))
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderOneLineView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let sectionContent = TableModelViewSection()
        
        let amountLabelModel = AmountInputViewModel(inputIdentifier: "amount", titleText: stringLoader.getString("extraContribution_text_amount"), textFormatMode: FormattedTextField.FormatMode.defaultCurrency(12, 2), dependencies: dependencies)
        
        let infoLabelModel = OperativeLabelTableModelView(title: stringLoader.getString("generic_text_infoHours"), style: LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 12), textAlignment: .center), insets: Insets(left: 14, right: 14, top: 5, bottom: 0), privateComponent: dependencies)
        
        sectionContent.items += [amountLabelModel, infoLabelModel]
        view.sections = [sectionHeader, sectionContent]
    }
        
    private func viewModelForIdentifier(identifier: String) -> String? {
        let sections = view.itemsSectionContent().compactMap({$0 as? InputIdentificable}).filter({$0?.inputIdentifier == identifier}).compactMap({$0})
        return sections.first?.dataEntered
    }
}

// MARK: - ExtraordinaryContributionAmountPresenterProtocol

extension ExtraordinaryContributionAmountPresenter: ExtraordinaryContributionAmountPresenterProtocol {
    func confirmButtonTouched() {
        let operativeData: ExtraContributionPensionOperativeData = containerParameter()
        guard let pension = operativeData.productSelected else {
            return
        }
        let contributionAmount = viewModelForIdentifier(identifier: "amount")
        let input = PreValidateExtraordinaryContributionUseCaseInput(amount: contributionAmount, originPension: pension)
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(with: dependencies.useCaseProvider.preValidateExtraordinaryContributionUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (result) in
                self?.hideAllLoadings(completion: { [weak self] in
                    guard let strongSelf = self else { return }
                    operativeData.extraContributionPension = result.extraContributionPension
                    strongSelf.container?.saveParameter(parameter: operativeData)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                })
            }, onError: { [weak self] error in
                self?.hideAllLoadings(completion: { [weak self] in
                    self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: error?.getErrorDesc())
                })
        })
    }
}
