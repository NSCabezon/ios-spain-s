import Foundation
import CoreFoundationLib

protocol SelectCardModifyPaymentFormDelegate: class {
    func selectedQuantity(quantity: Int, status: PaymentMethodStatus)
    func closeButton()
}

class SelectCardModifyPaymentFormPresenter: OperativeStepPresenter<SelectCardModifyPaymentFormViewController, ChangePaymentMethodNavigatorProtocol, SelectCardModifyPaymentFormPresenterProtocol> {
    private var cardModifyPaymentForm: CardModifyPaymentForm?
    private var orderedPaymentMethod: [PaymentMethod] = []
    
    // Card information
    var card: Card? {
        return cardModifyPaymentForm?.card
    }
    
    var cardTitle: String? {
        return card?.getAlias()
    }
    var cardSubtitle: String? {
        guard let card = card else {
            return nil
        }
        let panDescription = card.getPANShort()
        return dependencies.stringLoader.getString("pg_label_creditCard", [StringPlaceholder(.value, panDescription)]).text
    }
    var rightTitle: LocalizedStylableText? {
        return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
    }
    var amountText: String? {
        return card?.getAmountUI()
    }
    var cardImage: String? {
        return card?.buildImageRelativeUrl(true)
    }
    var imageLoader: ImageLoader {
        return dependencies.imageLoader
    }
    override var screenId: String? {
        return TrackerPagePrivate.CreditCardChangePayMethod().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_changeWayToPay")
        
        let operativeData: CardModifyPaymentFormOperativeData = containerParameter()
        cardModifyPaymentForm = operativeData.cardModifyPaymentForm
        infoObtained()
    }
    
    private func infoObtained() {
        let headerViewModel = GenericHeaderCardViewModel(title: .plain(text: cardTitle),
                                                         subtitle: .plain(text: cardSubtitle),
                                                         rightTitle: rightTitle != nil ? rightTitle : .plain(text: ""),
                                                         amount: .plain(text: amountText),
                                                         imageURL: cardImage,
                                                         imageLoader: imageLoader)
        
        let sectionHeader = TableModelViewSection()
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeCardHeaderView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let sectionTitle = TableModelViewSection()
        let titleLabelModel = OperativeLabelTableModelView(title: stringLoader.getString("changeWayToPay_label_payMethod"), style: LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16), textAlignment: .left), insets: Insets(left: 14, right: 14, top: 17, bottom: 10), titleIdentifier: "changeWayToPay_label_payMethodTitle",privateComponent: dependencies)
        sectionTitle.items = [titleLabelModel]
        
        let sectionContent = TableModelViewSection()
        guard let list = cardModifyPaymentForm?.currentChangePayment?.paymentMethodListFiltered else { return }
        let optionalPayment = addSelectPayment(elements: list)
        sectionContent.items = optionalPayment
        sectionContent.setItemsRounded()

        let footSection = TableModelViewSection()
        let foot = ClearLabelTableModelView(title: stringLoader.getString("changeWayToPay_label_consultConditions"), inputIndentifier: "changeWayToPay_footer", style: LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 13), textAlignment: .left), insets: Insets(left: 16, right: 12, top: 16, bottom: 16), privateComponent: dependencies)
        footSection.add(item: foot)
        
        view.sections = [sectionHeader, sectionTitle, sectionContent, footSection]
    }
    
    private func addSelectPayment(elements: [PaymentMethod]) -> [SelectCardModifyPaymentFormViewModel] {
        var array = [SelectCardModifyPaymentFormViewModel]()
        guard let list = cardModifyPaymentForm?.currentChangePayment?.paymentMethodListFiltered, let currenPaymentStatus = cardModifyPaymentForm?.currentChangePayment?.paymentMethodStatus else { return [] }
 
        for element in list {
            guard let paymentMethodStatus = element.paymentMethodStatus else { break }
            if list.contains(where: {$0.paymentMethodStatus == paymentMethodStatus}) {
                if let model = SelectCardModifyPaymentFormViewModel(inputIdentifier: "changeWayToPay", payment: element, radio: view.radio, subtitle: formatByStatus(status: paymentMethodStatus, title: element.getSubtitleCell().0, subtitle: element.getSubtitleCell().1), isInitialIndex: currenPaymentStatus == paymentMethodStatus, privateComponent: dependencies) {
                    array.append(model)
                    // Save paymethod in order to recover its value due the position in table
                    orderedPaymentMethod.append(element)
                }
            }
            // Save Operative data parameters
            if currenPaymentStatus == paymentMethodStatus {
                let operativeData: CardModifyPaymentFormOperativeData = containerParameter()
                operativeData.cardModifyPaymentForm?.amount = element.feeAmount
                operativeData.cardModifyPaymentForm?.oldAmount = element.feeAmount
                operativeData.cardModifyPaymentForm?.oldPaymentMethod = element
                operativeData.cardModifyPaymentForm?.newPaymentMethod = element
                container?.saveParameter(parameter: operativeData)
            }
        }
        
        return array
    }
    
    private func update(quantity: Int, status: PaymentMethodStatus) {
        let operativeData: CardModifyPaymentFormOperativeData = containerParameter()
        operativeData.cardModifyPaymentForm?.newPaymentMethodStatus = status
        operativeData.cardModifyPaymentForm?.amount = Amount.createWith(value: Decimal(quantity))
        operativeData.cardModifyPaymentForm?.newPaymentMethod = getPaymentMethodByStatus(status: status)
        
        let amount = Int(operativeData.cardModifyPaymentForm?.newPaymentMethod?.minAmortAmount?.value?.doubleValue ?? 0.0)
        container?.saveParameter(parameter: operativeData)
        updateRadioCell(status: status, title: quantity, subtitle: amount)
    }
    
    private func getPaymentMethodByStatus(status: PaymentMethodStatus) -> PaymentMethod? {
        return orderedPaymentMethod.filter { $0.paymentMethodStatus == status }.first ?? nil
    }
    
    private func updateRadioCell(status: PaymentMethodStatus, title: Int, subtitle: Int) {
        guard let index = orderedPaymentMethod.firstIndex(where: { item -> Bool in
            item.paymentMethodStatus == status
        }) else { return }
        let indexPath = IndexPath(item: index, section: 2)
        
        let subtitleCell: LocalizedStylableText = formatByStatus(status: status, title: title, subtitle: subtitle)
        viewModelForIdentifier(identifier: status.rawValue, subtitle: subtitleCell)
        view.radio.didSelectCellComponent(indexPath: indexPath)
    }
    
    private func formatByStatus(status: PaymentMethodStatus, title: Int, subtitle: Int) -> LocalizedStylableText {
        var result = LocalizedStylableText.empty
        if status == .fixedFee {
            result = dependencies.stringLoader.getString("changeWayToPay_label_fixedFeeNumValue", [StringPlaceholder(.value, String(title))])
            dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.CreditCardChangePayMethodFixedFee().page, extraParameters: [:])
        } else if status == .deferredPayment {
            result = dependencies.stringLoader.getString("changeWayToPay_label_postponeNumValue",
                                                         [StringPlaceholder(StringPlaceholder.Placeholder.number, formatterForRepresentation(.decimal(decimals: 0)).string(from: NSNumber(value: title)) ?? ""),
                                                          StringPlaceholder(StringPlaceholder.Placeholder.value, String(subtitle))])
            dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.CreditCardChangePayMethodDeferred().page, extraParameters: [:])
        }
        return result
    }
    
    private func viewModelForIdentifier(identifier: String, subtitle: LocalizedStylableText) {
        let sections = view.itemsSectionContent().compactMap({$0 as? UpdateIdentificable}).filter({$0?.inputIdentifier == identifier}).compactMap({$0})
        sections.first?.updateSubtitleInfo(subtitle: subtitle)
    }
}

// MARK: Presenter protocol
extension SelectCardModifyPaymentFormPresenter: SelectCardModifyPaymentFormPresenterProtocol {
    var infoTitle: LocalizedStylableText {
        return stringLoader.getString("toolbar_title_changeWayToPay")
    }
    
    var toolTipMessage: LocalizedStylableText {
        return stringLoader.getString("tooltip_label_changeWayToPay")
    }
    
    // When the user selects an option, the app goes to the selection screen. If the selection is different from previous one then the value selected is the minimum
    func selected(indexPath: IndexPath) {
        if indexPath.section != 2 { return }
        
        let operativeData: CardModifyPaymentFormOperativeData = containerParameter()
        let paymentMethod = orderedPaymentMethod[indexPath.row]
        guard let paymentMethodStatus = paymentMethod.paymentMethodStatus else { return }
        let amount = Int(paymentMethod.minAmortAmount?.value?.doubleValue ?? 0.0)
        var subtypes: [Int] = []
        var title: LocalizedStylableText
        var descriptionKey: String
        
        switch paymentMethodStatus {
        case .fixedFee:
            subtypes = createArrayPaymentSubtypeAmount(paymentMethod: paymentMethod)
            guard let firstElement = subtypes.first else { return }
            descriptionKey = dependencies.stringLoader.getString("fixedFee_label_selectBalance", [StringPlaceholder(.value, String(firstElement))]).text
            title = dependencies.stringLoader.getString("toolbar_title_fixedFee")
        case .deferredPayment:
            subtypes = createArrayPaymentSubtypePercentage(paymentMethod: paymentMethod)
            guard let firstElement = subtypes.first else { return }
            title = dependencies.stringLoader.getString("changeWayToPay_label_postpone")
            descriptionKey = dependencies.stringLoader.getString("postpone_label_selectBalance", [StringPlaceholder(.number, String(firstElement)), StringPlaceholder(.value, String(amount))]).text
        case .monthlyPayment:
            update(quantity: 100, status: .monthlyPayment)
            return
        default:
            // Doing nothing. Posible future options
            return
        }
        
        if operativeData.cardModifyPaymentForm?.newPaymentMethodStatus != paymentMethodStatus {
            changeCellWithFirstElement(subtypes: subtypes, status: paymentMethodStatus)
        }
        
        let previous = Int(operativeData.cardModifyPaymentForm?.amount?.value?.doubleValue ?? 0.0)
        let info = PaymentMethodSubtypeInfo(status: paymentMethodStatus, previousValue: previous, subtypes: subtypes, amountPercentage: amount, title: title, paymentMethodDescriptionKey: descriptionKey)
        navigator.goToSelectSubtype(delegate: self, info: info)
    }
    
    private func createArrayPaymentSubtypeAmount(paymentMethod: PaymentMethod) -> [Int] {
        let subtypes = paymentMethod.getRangeAmount()
        return subtypes.map { $0 }
    }
    
    private func createArrayPaymentSubtypePercentage(paymentMethod: PaymentMethod) -> [Int] {
        let subtypes = paymentMethod.getRangePercentage()
        return subtypes.map { $0 }
    }
    
    private func changeCellWithFirstElement(subtypes: [Int], status: PaymentMethodStatus) {
        guard let firstElement = subtypes.first else { return }
        update(quantity: firstElement, status: status)
    }
    
    // MARK: Continue button
    func onContinueButtonClicked() {
        if checkContinue() {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "changeWayToPay_error_validationChangePay")
            return
        }
        container?.stepFinished(presenter: self)
    }
    
    func checkContinue() -> Bool {
        guard let operativeData: CardModifyPaymentFormOperativeData = container?.provideParameter(),
            let newPaymentMethodStatus = operativeData.cardModifyPaymentForm?.newPaymentMethodStatus,
            let currenPaymentMethodStatus = operativeData.cardModifyPaymentForm?.currentChangePayment?.paymentMethodStatus,
            let amount = operativeData.cardModifyPaymentForm?.amount,
            let oldAmount = operativeData.cardModifyPaymentForm?.oldAmount
            else { return false }
        return newPaymentMethodStatus == currenPaymentMethodStatus && oldAmount == amount
    }
    
    // MARK: Tooltips.
    func auxiliaryButtonAction(tag: Int, completion: (RadioTableAuxiliaryAction) -> Void) {
        var action: RadioTableAuxiliaryAction = .none
        switch tag {
        case 0:
            action = .toolTip(title: dependencies.stringLoader.getString("tooltip_title_monthly"), description: nil, localizedDesription: dependencies.stringLoader.getString("tooltip_label_monthly"), identifier: "changeWayToPay_toolTipMonthly", delegate: view)
        case 1:
            if let deferredPaymentMethod = orderedPaymentMethod.first { $0.paymentMethodStatus == .deferredPayment },
               let number = deferredPaymentMethod.minModeAmount?.value,
               let value = deferredPaymentMethod.minAmortAmount?.value {
                let localizedDescription = dependencies.stringLoader.getString("tooltip_label_postpone",
                                                                               [StringPlaceholder(.number, String(describing: number)),
                                                                                StringPlaceholder(.value, String(describing: value))])
                action = .toolTip(title: dependencies.stringLoader.getString("tooltip_title_postpone"), description: nil, localizedDesription: localizedDescription, identifier: "changeWayToPay_toolTipPostpone", delegate: view)
            }
        case 2:
            if let fixedFeePaymentMethod = orderedPaymentMethod.first { $0.paymentMethodStatus == .fixedFee },
               let value = fixedFeePaymentMethod.minModeAmount?.value {
                let localizedDescription = dependencies.stringLoader.getString("tooltip_label_fixedFee", [StringPlaceholder(.value, String(describing: value))])
                action = .toolTip(title: dependencies.stringLoader.getString("tooltip_title_fixedFee"), description: nil, localizedDesription: localizedDescription, identifier: "changeWayToPay_toolTipFixedFee", delegate: view)
            }
        default:
            break
        }
        completion(action)
    }
}

extension SelectCardModifyPaymentFormPresenter: SelectCardModifyPaymentFormDelegate {
    func selectedQuantity(quantity: Int, status: PaymentMethodStatus) {
        update(quantity: quantity, status: status)
        navigator.goBack()
    }
    
    func closeButton() {
         container?.cancelTouched(completion: nil)
    }
}
