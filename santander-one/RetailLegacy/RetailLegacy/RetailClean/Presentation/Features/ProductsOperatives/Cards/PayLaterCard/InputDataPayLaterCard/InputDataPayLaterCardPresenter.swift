import Foundation
import CoreFoundationLib

final class InputDataPayLaterCardPresenter: OperativeStepPresenter<InputDataPayLaterCardViewController, VoidNavigator, InputDataPayLaterCardPresenterProtocol> {
    private var payLaterCard: PayLaterCard?
    
    var card: Card? {
        return payLaterCard?.originCard
    }
    
    var cardTitle: String? {
        return card?.getAlias()
    }
    
    var cardSubtitle: String? {
        guard let card = card, let pan = card.getDetailUI().substring(card.getDetailUI().count - 4) else {
            return nil
        }
        let panDescription = "***" + pan
        return dependencies.stringLoader.getString("pg_label_creditCard", [StringPlaceholder(.value, panDescription)]).text
    }
    
    var rightTitle: LocalizedStylableText? {
        return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
    }
    
    var amountText: String? {
        return card?.getAmount()?.getAbsFormattedAmountUI() ?? ""
    }
    
    var minimumValue: String? {
        guard let amountPercent = payLaterCard?.percentageAmount.value else { return "" }
        if amountPercent == 25.0 {
            return payLaterCard?.percentageAmount.getFormattedAmountUI(0)
        }
        return payLaterCard?.percentageAmount.getAbsFormattedAmountUI() ?? ""
    }
    
    var cardImage: String? {
        return card?.buildImageRelativeUrl(true)
    }
    
    var imageLoader: ImageLoader {
        return dependencies.imageLoader
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("toolbar_title_payLater")
        let operativeData: PayLaterCardOperativeData = containerParameter()
        payLaterCard = operativeData.payLaterCard
        infoObtained()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.PayLater().page
    }
    
    private func infoObtained() {
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        view.continueButton.onTouchAction = { [weak self] _ in
            self?.onContinueButtonClicked()
        }
        
        let sectionHeader = TableModelViewSection()
        let headerViewModel = GenericHeaderCardViewModel(title: .plain(text: cardTitle),
                                                    subtitle: .plain(text: cardSubtitle),
                                                    rightTitle: rightTitle != nil ? rightTitle : .plain(text: ""),
                                                    amount: .plain(text: amountText),
                                                    imageURL: cardImage,
                                                    imageLoader: imageLoader)
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel,
                                                viewType: GenericOperativeCardHeaderView.self,
                                                dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let sectionContent = TableModelViewSection()
        
        let titleLabelModel = OperativeLabelTooltipTableModelView(title: stringLoader.getString("payLater_title_wantToPay"),
                                                                  style: LabelStylist(textColor: .sanGreyDark,
                                                                                      font: .latoBold(size: 16),
                                                                                      textAlignment: .left),
                                                                  insets: Insets(left: 14, right: 14, top: 17, bottom: 4),
                                                                  privateComponent: dependencies,
                                                                  tooltipText: stringLoader.getString("payLater_label_amountPay"),
                                                                  titleIdentifier: AccessibilityCardPayLater.payLaterWantToPay)
        let amountLabelModel = AmountInputViewModel(inputIdentifier: "amount",
                                                    textFormatMode: FormattedTextField.FormatMode.defaultCurrency(4, 2),
                                                    dependencies: dependencies,
                                                    titleIdentifier: AccessibilityCardPayLater.amountInputTitle,
                                                    textInputIdentifier: AccessibilityCardPayLater.amountInputInput,
                                                    textInputRightImageIdentifier: AccessibilityCardPayLater.amountInputImage)
        
        let infoViewModel = OperatorInfoViewModel(delegate: self, dependencies: dependencies, descriptionLeftIdentifier: "payLater_infoPay_leftDesc", descriptionRightIdentifier: "payLater_infoPay_rightDesc", bottomLabelIdentifier: "payLater_infoPay_bottomLabel")
        
        sectionContent.items += [titleLabelModel, amountLabelModel, infoViewModel]
        view.sections = [sectionHeader, sectionContent]
    }
}

extension InputDataPayLaterCardPresenter: OperatorInformationProvider {
    var minimumAmount: LocalizedStylableText? {
        guard let minimum = minimumValue else { return nil }
        let placeholderMinimum = StringPlaceholder(.value, minimum)
    
        return stringLoader.getString("payLater_text_minAmount", [placeholderMinimum])
    }
    
    var maximumAmount: LocalizedStylableText? {
        guard let maximum = amountText else { return nil }
        let placeholderMaximum = StringPlaceholder(.value, maximum)
        return stringLoader.getString("payLater_text_maxAmount", [placeholderMaximum])
    }
    
    var intervalAmount: LocalizedStylableText? {
        return .empty
    }
    
    func operatorName() -> String? {
        return ""
    }
    
    private func viewModelForIdentifier(identifier: String) -> String? {
        let sections = view.itemsSectionContent().compactMap({$0 as? InputIdentificable}).filter({$0?.inputIdentifier == identifier}).compactMap({$0})
        return sections.first?.dataEntered
    }
}

extension InputDataPayLaterCardPresenter: InputDataPayLaterCardPresenterProtocol {    
    func onContinueButtonClicked() {
        guard let availableBalance = card?.getAmount(), let amountPercent = payLaterCard?.percentageAmount else {
            return
        }        
        guard let enteredAmount = viewModelForIdentifier(identifier: "amount"), !enteredAmount.isEmpty else {
            self.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "generic_alert_text_errorAmount")
            return
        }
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
           
        let caseInput = PrevalidatePayLaterCardUseCaseInput(percentageAmount: amountPercent, availableBalance: availableBalance, stringData: enteredAmount)
        UseCaseWrapper(with: useCaseProvider.prevalidatePayLaterCardUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] _ in
            guard let strongSelf = self else { return }            
            guard let availableBalanceDecimal = availableBalance.value, let enteredAmountDecimal = enteredAmount.stringToDecimal else { return }
            let amountPayLater = abs(availableBalanceDecimal) - enteredAmountDecimal
            
            let operativeData: PayLaterCardOperativeData = strongSelf.containerParameter()
            operativeData.payLaterCard?.amountToPayLater = Amount.createWith(value: amountPayLater)
            operativeData.payLaterCard?.amountToDefer = Amount.createWith(value: enteredAmountDecimal)
            strongSelf.container?.saveParameter(parameter: operativeData)

            strongSelf.hideLoading(completion: {
                strongSelf.container?.stepFinished(presenter: strongSelf)
            })
            }, onError: { [weak self] (error) in
                guard let strongSelf = self else { return }
                strongSelf.hideLoading(completion: {
                    let errorKey: String
                    switch error?.payLaterError {
                    case .empty?:
                        errorKey = "generic_alert_text_errorAmount"
                    case .zero?:
                        errorKey = "generic_alert_text_errorData_amount"
                    case .minorThanMinimum?:
                        errorKey = "payLater_alert_higherValue"
                    case .minorThanPercent?:
                        errorKey = "payLater_alert_higherBalance"
                    case .greaterThanAvailableBalance?:
                        errorKey = "payLater_alert_lowerBalance"
                    case .invalid?, nil:
                        errorKey = "generic_alert_text_errorData_numberAmount"
                    }
                    strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: errorKey)
                })
                
        })
    }
}
