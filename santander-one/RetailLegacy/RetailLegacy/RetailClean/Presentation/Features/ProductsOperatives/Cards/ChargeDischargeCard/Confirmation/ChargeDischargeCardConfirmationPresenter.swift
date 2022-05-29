import Foundation
import CoreFoundationLib

class ChargeDischargeCardConfirmationPresenter: OperativeStepPresenter<ChargeDischargeCardConfirmationViewController, VoidNavigator, ChargeDischargeCardConfirmationPresenterProtocol> {
    
    private lazy var card: Card? = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.productSelected
    }()
    
    private lazy var account: Account? = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.account
    }()
    
    private lazy var inputType: ChargeDischargeType? = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.inputType
    }()
    
    private lazy var inputTypeAmount: String? = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.inputType?.getAmount()
    }()
    
    private lazy var cardHolder: String? = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.prepaidCardData?.holderName
    }()
    
    private lazy var comission: Amount = {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        return operativeData.validatePrepaidCard?.preliqData.bankCharge ?? Amount.zero()
    }()
    
    private var cardImage: String? {
        guard let card = card else { return nil }
        return card.buildImageRelativeUrl(true)
    }
    
    // MARK: - Tracker
    
    override var screenId: String? {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        
        guard let inputType = operativeData.inputType else {
            return nil
        }
        
        switch inputType {
        case .charge:
            return TrackerPagePrivate.CardsChargeConfirmation().page
        case .discharge:
            return TrackerPagePrivate.CardsDischargeConfirmation().page
        }
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        
        guard let inputType = operativeData.inputType else {
            return
        }
        
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")
        
        let originAccountSection = TableModelViewSection()
        
        let originAccountHeader = TitledTableModelViewHeader()
        originAccountHeader.title = stringLoader.getString("confirmationDepositCard_label_originAccount")
        originAccountHeader.titleIdentifier = AccessibilityCardChargeDischarge.confirmationTitleAccount
        originAccountSection.setHeader(modelViewHeader: originAccountHeader)
        let accountItem = AccountConfirmationViewModel(accountName: account?.getAlias() ?? stringLoader.getString("generic_confirm_associatedAccount").text, ibanNumber: account?.getIBANShort(), amount: account?.getAmountUI(), privateComponent: dependencies)
        originAccountSection.items = [accountItem]
        
        let chargeSection = TableModelViewSection()
        let chargeHeader = TitledTableModelViewHeader()        
        switch inputType {
        case .charge:
             chargeHeader.title = stringLoader.getString("chargeDischarge_label_chargeCard")
        case .discharge:
             chargeHeader.title = stringLoader.getString("chargeDischarge_label_dischargeCard")
        }
        chargeHeader.titleIdentifier = AccessibilityCardChargeDischarge.confirmationTitleCard
        chargeSection.setHeader(modelViewHeader: chargeHeader)
        
        switch Decimal.getAmountParserResult(value: inputTypeAmount) {
        case .success(let decimalValue):
            let amount = Amount.createWith(value: decimalValue)
            let amountItem = PayOffHeaderAmountViewModel(amount.getFormattedAmountUI(), identifier: AccessibilityCardChargeDischarge.confirmCardItemBase, dependencies)
            chargeSection.items.append(amountItem)
        default:
            break
        }
        
        guard let card = card, let cardHolder = cardHolder else { return }
        
        let cardHeaderItem = PayOffConfirmationCardViewModel(alias: card.getAlias(),
                                                             amount: card.getAmountUI(),
                                                             imageURL: cardImage ?? "",
                                                             imageLoader: dependencies.imageLoader,
                                                             identifiers: (AccessibilityCardChargeDischarge.confirmCardAlias, AccessibilityCardChargeDischarge.confirmCardAmount, AccessibilityCardChargeDischarge.confirmCardImage),
                                                             privateComponent: dependencies)
        chargeSection.items.append(cardHeaderItem)
        
        let cardNumberItem = ConfirmationTableViewItemModel(dependencies.stringLoader.getString("confirmationDepositCard_item_numberCard"), card.getDetailUI(), false, dependencies, accessibilityIdentifier: AccessibilityCardChargeDischarge.confirmNumberView, descriptionIdentifier: AccessibilityCardChargeDischarge.confirmNumberDesc, valueIdentifier: AccessibilityCardChargeDischarge.confirmNumberValue)
        chargeSection.add(item: cardNumberItem)
        
        let ownerNameItem = ConfirmationTableViewItemModel(dependencies.stringLoader.getString("confirmation_item_holder"), cardHolder.capitalized, false, dependencies, accessibilityIdentifier: AccessibilityCardChargeDischarge.confirmOwnerView, descriptionIdentifier: AccessibilityCardChargeDischarge.confirmOwnerDesc, valueIdentifier: AccessibilityCardChargeDischarge.confirmOwnerValue)
        chargeSection.add(item: ownerNameItem)
        
        let dateItem = ConfirmationTableViewItemModel(dependencies.stringLoader.getString("confirmation_item_date"), dependencies.timeManager.toString(date: Date(), outputFormat: TimeFormat.d_MMM_yyyy) ?? "", false, dependencies, accessibilityIdentifier: AccessibilityCardChargeDischarge.confirmDateView, descriptionIdentifier: AccessibilityCardChargeDischarge.confirmDateDesc, valueIdentifier: AccessibilityCardChargeDischarge.confirmDateValue)
        chargeSection.add(item: dateItem)
        
        let comissionItem = ConfirmationTableViewItemModel(dependencies.stringLoader.getString("chargeDischarge_label_commission"), comission.getFormattedAmountUI(), true, dependencies, accessibilityIdentifier: AccessibilityCardChargeDischarge.confirmCommissionView, descriptionIdentifier: AccessibilityCardChargeDischarge.confirmCommissionDesc, valueIdentifier: AccessibilityCardChargeDischarge.confirmCommissionValue)
        chargeSection.add(item: comissionItem)
        
        view.sections = [originAccountSection, chargeSection]
    }
}

extension ChargeDischargeCardConfirmationPresenter: ChargeDischargeCardConfirmationPresenterProtocol {
    func confirmButtonTouched() {
        let operativeData: ChargeDischargeCardOperativeData = containerParameter()
        guard let account = operativeData.account, let inputType = operativeData.inputType, let card = operativeData.productSelected, let prepaidCardData = operativeData.prepaidCardData else {
            return
        }      
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = ValidateChargeDischargeUseCaseInput(inputType: inputType, card: card, account: account, prepaidCardData: prepaidCardData)
        UseCaseWrapper(with: useCaseProvider.validateChargeDischargeUseCase(input: input), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (result) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.container?.saveParameter(parameter: result.signature)
            strongSelf.hideLoading(completion: {
                strongSelf.container?.stepFinished(presenter: strongSelf)
            })
        }, onError: { [weak self] (error) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.hideLoading(completion: {
                strongSelf.showError(keyTitle: "", keyDesc: error?.getErrorDesc())
            })
        })
    }
}
