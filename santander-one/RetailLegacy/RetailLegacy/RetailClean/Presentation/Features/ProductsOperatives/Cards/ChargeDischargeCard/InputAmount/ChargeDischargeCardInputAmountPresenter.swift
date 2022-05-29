import Foundation
import CoreFoundationLib

class ChargeDischargeCardInputAmountPresenter: OperativeStepPresenter<FormViewController, VoidNavigator, FormPresenterProtocol> {
    
    private let operationTypeIdentifier = "operationType"
    
    private lazy var card: Card? = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.productSelected
        
    }()
    
    private lazy var account: Account? = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.account
    }()
    
    private lazy var minAllowed: Double? = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.minAllowed
    }()
    
    private lazy var maxAllowed: Double? = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.maxAllowed
    }()
    
    private lazy var topUpOptions: [String] = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.topUpOptions
    }()
    
    private lazy var withdrawOptions: [String] = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.withdrawOptions
    }()
    
    var cardTitle: String {
        return card?.getAlias() ?? ""
    }
    
    var cardSubtitle: String? {
        guard let card = self.card else { return nil }
        let panDescription = card.getPANShort()
        let key: String
        if card.isPrepaidCard {
            key = "pg_label_ecashCard"
        } else if card.isCreditCard {
            key = "pg_label_creditCard"
        } else {
            key = "pg_label_debitCard"
        }
        return dependencies.stringLoader.getString(key, [StringPlaceholder(.value, panDescription)]).text
    }
    var rightTitle: LocalizedStylableText? {
        guard let card = self.card else { return nil }
        if card.isPrepaidCard {
            return dependencies.stringLoader.getString("pg_label_balanceDots")
        } else if card.isCreditCard {
            return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
        } else {
            return nil
        }
    }
    var amountText: String? {
        guard let card = self.card else { return nil }
        return card.getAmountUI()
    }
    var cardImage: String? {
        guard let card = self.card else { return nil }
        return card.buildImageRelativeUrl(true)
    }
    var imageLoader: ImageLoader {
        return dependencies.imageLoader
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_chargeDischarge")
        infoObtained()
    }
    
    // MARK: - tracker
    override var screenId: String? {
        return TrackerPagePrivate.CardsChargeDischargeAmount().page
    }
    
    private func buildCardDescriptionFor(_ card: Card) -> String {
        let panDescription = card.getPANShort()
        let key: String
        if card.isPrepaidCard {
            key = "pg_label_ecashCard"
        } else if card.isCreditCard {
            key = "pg_label_creditCard"
        } else {
            key = "pg_label_debitCard"
        }
        
        return dependencies.stringLoader.getString(key, [StringPlaceholder(.value, panDescription)]).text
    }

    private func infoObtained() {
        
        var sections = [StackSection]()
        let sectionHeader = StackSection()
        
        guard let card = card else {
            return
        }
        
        let cardDescription = buildCardDescriptionFor(card)
        let header = CardHeaderStackModel(cardTitle: card.getAlias(), cardDescription: cardDescription, titleAmount: stringLoader.getString(card.cardHeaderAmountInfoKey), amount: card.getAmountUI(), imageURL: card.buildImageRelativeUrl(true), imageLoader: dependencies.imageLoader, identifier: AccessibilityCardChargeDischarge.chargeOrDischargeCardHeader)
        sectionHeader.add(item: header)
        sections.append(sectionHeader)
        
        sections.append(buildOptionsSection())
        view.dataSource.reloadSections(sections: sections)
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
    }
    
    private func buildOptionsSection() -> StackSection {
        let section = StackSection()
        
        let title = TitleLabelStackModel(title: dependencies.stringLoader.getString("generic_label_selectOpcions"), identifier: AccessibilityCardChargeDischarge.chargeOrDischargeOptionsTitle, insets: Insets(left: 10, right: 10, top: 30, bottom: 0))
        section.add(item: title)
        var topUpPlaceHolder: LocalizedStylableText?
        if let minimum = minAllowed, let maximum = maxAllowed {
            topUpPlaceHolder = createTopUpPlaceHolder(maximum: maximum, minimum: minimum)
        }
        let topUpAmountOptions = topUpOptions.map { ValueOptionType(value: $0, displayableValue: $0.amountAndCurrency()) }
        let withdrawAmountOptions = withdrawOptions.map { ValueOptionType(value: $0, displayableValue: $0.amountAndCurrency()) }
        let topUp = createTopUpOption(placeholder: topUpPlaceHolder, identifier: AccessibilityCardChargeDischarge.chargeOrDischargeOptionCharge, options: topUpAmountOptions)
        let withdraw = createWithdrawOption(placeholder: stringLoader.getString("generic_hint_amount"), identifier: AccessibilityCardChargeDischarge.chargeOrDischargeOptionDischarge, options: withdrawAmountOptions)
        let options: [RadioOptionData] = [topUp, withdraw]
        let topUpWithdraw = RadioExpandableStackModel(inputIdentifier: operationTypeIdentifier, options: options, insets: Insets(left: 0, right: 0, top: 10, bottom: 0), nextType: .none)
        section.add(item: topUpWithdraw)
        return section
    }

    private func createTopUpPlaceHolder(maximum: Double, minimum: Double) -> LocalizedStylableText {
        let minimumAmount = Amount.createWith(value: Decimal(minimum))
        let maximumAmount = Amount.createWith(value: Decimal(maximum))
        
        return stringLoader.getString("chargeDischarge_label_minMax", [StringPlaceholder(.value, minimumAmount.getFormattedAmountUI(floor(minimum) == minimum ? 0 : 2)), StringPlaceholder(.value, maximumAmount.getFormattedAmountUI(0))])
    }
    
    private func createTopUpOption(placeholder: LocalizedStylableText?, identifier: String? = nil, options: [ValueOptionType]) -> RadioOptionData {
        return RadioOptionData(isSelected: false, placeholder: placeholder, title: stringLoader.getString("chargeDischarge_label_charge"), identifier: identifier, options: options, encodeData: { amount in
            guard let amount = amount else { return nil }
            return ChargeDischargeType.charge(amount: amount).encode
        })
    }
    
    private func createWithdrawOption(placeholder: LocalizedStylableText?, identifier: String? = nil, options: [ValueOptionType]) -> RadioOptionData {
        return RadioOptionData(isSelected: false, placeholder: placeholder, title: stringLoader.getString("chargeDischarge_label_discharge"), identifier: identifier, options: options, encodeData: { amount in
            guard let amount = amount else { return nil }
            return ChargeDischargeType.discharge(amount: amount).encode})
    }
    
}

extension ChargeDischargeCardInputAmountPresenter: FormPresenterProtocol {
    
    func onContinueButtonClicked() {
        
        let encodedOperationType = view.dataSource.findData(identifier: operationTypeIdentifier)
        
        guard let card = card, let operationType = ChargeDischargeType.decode(encodedOperationType) else {
            showError(keyTitle: "otp_titlePopup_error", keyDesc: "generic_error_radiobuttonNull", phone: nil, completion: nil)
            return
        }
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(with: useCaseProvider.preValidateChargeDischargeAmountUseCase(input: PreValidateChargeDischargeAmountUseCaseInput(card: card, type: operationType)), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (_) in
            guard let strongSelf = self, let account = strongSelf.account  else {
                return
            }
            
            let operativeData: ChargeDischargeCardOperativeData = strongSelf.containerParameter()
            
            guard let card = strongSelf.card, let prepaidCardData = operativeData.prepaidCardData else { return }
            
            let input = ValidateChargeDischargeUseCaseInput(inputType: operationType, card: card, account: account, prepaidCardData: prepaidCardData)
            
            UseCaseWrapper(with: strongSelf.useCaseProvider.validateChargeDischargeUseCase(input: input), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] (validationResponse) in
                guard let strongSelf2 = self else { return }
                
                operativeData.inputType = operationType
                operativeData.validatePrepaidCard = validationResponse.validatePrepaidCard
                strongSelf.container?.saveParameter(parameter: operativeData)
                strongSelf.container?.saveParameter(parameter: validationResponse.signature)
                strongSelf.hideLoading(completion: {
                    strongSelf.container?.stepFinished(presenter: strongSelf2)
                })
                }, onError: { [weak self] (errorResponse) -> Void in
                    guard let strongSelf = self else { return }
                    strongSelf.hideLoading(completion: {
                        strongSelf.showError(keyDesc: errorResponse?.getErrorDesc())
                    })
            })
            }, onError: { [weak self] (error) -> Void in
                guard let strongSelf = self else { return }
                let description: String?
                if let minDouble = error?.minAmount, let maxDouble = error?.maxAmount {
                    let minAmount = Amount.createWith(value: Decimal(minDouble))
                    let maxAmount = Amount.createWith(value: Decimal(maxDouble))
                    let errorString = strongSelf.stringLoader.getString(error?.getErrorDesc() ?? "", [StringPlaceholder(.value, minAmount.getFormattedAmountUI(floor(minDouble) == minDouble ? 0 : 2)), StringPlaceholder(.value, maxAmount.getFormattedAmountUI(floor(maxDouble) == maxDouble ? 0 : 2))]).text
                    description = errorString
                } else {
                    description = error?.getErrorDesc()
                }
                strongSelf.hideLoading(completion: {
                    strongSelf.showError(keyTitle: error?.errorTitle, keyDesc: description)
                })
        })
        
    }
    
}

private extension ChargeDischargeType {
    static let topUp = "topUp"
    static let withdraw = "withdraw"
    
    var encode: String? {
        switch self {
        case let .charge(amount):
            return ChargeDischargeType.topUp + "#" + amount
        case let .discharge(amount):
            return ChargeDischargeType.withdraw + "#" + amount
        }
    }
    
    static func decode(_ value: String?) -> ChargeDischargeType? {
        guard let parts = value?.split(separator: "#"), parts.count > 1 else {
            return nil
        }
        let option = String(parts[0])
        let amount = String(parts[1])
        switch option {
        case ChargeDischargeType.topUp:
            return ChargeDischargeType.charge(amount: amount)
        case ChargeDischargeType.withdraw:
            return ChargeDischargeType.discharge(amount: amount)
        default:
            return nil
        }
    }
}
