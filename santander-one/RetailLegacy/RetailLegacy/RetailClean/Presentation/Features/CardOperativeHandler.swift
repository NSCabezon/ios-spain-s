import CoreFoundationLib

class ActivateCardAction: CardActivationLauncher {
    let dependencies: PresentationComponent
    let errorHandler: GenericPresenterErrorHandler
    let origin: OperativeLaunchedFrom
    private weak var delegate: OperativeLauncherDelegate?
    
    init(dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, launchedFrom: OperativeLaunchedFrom, delegate: OperativeLauncherDelegate) {
        self.dependencies = dependencies
        self.errorHandler = errorHandler
        self.origin = launchedFrom
        self.delegate = delegate
    }
}

extension ActivateCardAction: CardActivator {
    func activate(card: Card) {
        guard let delegate = delegate else { return }
        activateCard(card, launchedFrom: origin, delegate: delegate)
    }
}

protocol CardOperativeHandler: CardActivationLauncher, CardBlockCardLauncher, CardMobileTopUpLauncher, CardCESSignUpLauncher, CardWithdrawalMoneyWithCodeLauncher, CardPINQueryCardLauncher, CardCVVQueryCardLauncher, CardPayOffLauncher, CardPayLaterCardLauncher, CardChargeDischargeLauncher, CardPdfLauncher, ApplePayLauncher, CardDirectMoneyLauncher, CardLimitManagementLauncher, CardModifyPaymentFormLauncher {
    
}

extension CardOperativeHandler {    
    func optionDidSelected(at index: Int, product: Card, presenterOffers: [PullOfferLocation: Offer]?, delegate: ProductLauncherOptionsPresentationDelegate?) {
        if let optionSelected = ProductsOptions.CardOptions(rawValue: index) {
            switch optionSelected {
            case .activateCard:
                if product.isInactive == true {
                    guard let delegate = delegate else {
                        return
                    }
                    ActivateCardAction(dependencies: dependencies, errorHandler: errorHandler, launchedFrom: .home, delegate: delegate).activate(card: product)
                }
            case .directMoney:
                guard let delegate = delegate else { return }
                goToDirectMoneyOperative(card: product, launchedFrom: .home, delegate: delegate)
            case .paylater:
                guard let delegate = delegate else { return }
                showPayLaterCard(card: product, delegate: delegate)
            case .payOff:
                guard let delegate = delegate else { return }
                goToPayOff(product, delegate: delegate)
            case .prepaidCharge:
                guard let delegate = delegate else { return }
                showCardChargeDischargeCard(product, delegate: delegate)
            case .pinQuery:
                guard let delegate = delegate else { return }
                showPINQueryCard(product, delegate: delegate)
            case .CVVQuery:
                guard let delegate = delegate else { return }
                showCVVQueryCard(product, delegate: delegate)
            case .blockCard:
                blockCard(product, delegate: delegate)
            case .mobilePay:
                goToApplePay()
            case .mobileTopUp:
                mobileTopUp(card: product, delegate: delegate)
            case .withdrawMoneyWithCode:
                guard let delegate = delegate else { return }
                showWithdrawMoneyWithCode(product, delegate: delegate)
            case .ces:
                guard let delegate = delegate else { return }
                signupCesCard(product, delegate: delegate)
            case .pdf:
                dateForPdf(product: product)
            case .cardLimitManagement:
                guard let delegate = delegate else { return }
                goToCardLimitManagementOperative(card: product, delegate: delegate)
            case .solidary:
                guard let presenterOffers = presenterOffers, let offer = presenterOffers[.REDONDEO_SOLIDARIO], let action = offer.action else {
                    return
                }
                delegate?.executePullOfferAction(action: action, offerId: offer.id, location: .REDONDEO_SOLIDARIO)
            case .modifyPaymentForm:
                guard let delegate = delegate else { return }
                modifyPayment(product: product, delegate: delegate)
            case .purchaseCard:
                guard let offer = presenterOffers?[.CONTRATAR_TARJETAS], let action = offer.action else {
                    return
                }
                delegate?.executePullOfferAction(action: action, offerId: offer.id, location: .CONTRATAR_TARJETAS)
            }
        }
    }
}
