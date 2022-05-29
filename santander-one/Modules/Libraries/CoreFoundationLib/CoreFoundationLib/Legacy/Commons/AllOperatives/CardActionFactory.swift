//
//  CardActionFactory.swift
//  Commons
//
//  Created by David Gálvez Alonso on 10/02/2020.
//

import Foundation

public class CardActionFactory {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func getCardOperativesButtons(action: ((Any, AllOperatives) -> Void)?, enabledActions: [CardOperativeActionType]?, originalImages: [CardOperativeActionType]?) -> [AllOperativesViewModel] {
        guard let enabledActions = enabledActions else {
            return []
        }
        let actions: [AllOperativesViewModel] = enabledActions.map { (option) in
            switch option {
            case .custom(let values):
                return AllOperativesViewModel(title: localized(values.localizedKey),
                                              type: option,
                                              viewType: option.getViewType(),
                                              entity: .cardsActions,
                                              action: action,
                                              isDisabled: false,
                                              renderingMode: values.renderingMode)
            default:
                let optionValues = option.values()
                let renderingMode = originalImages?.contains(option) ?? false ? UIImage.RenderingMode.alwaysOriginal : UIImage.RenderingMode.alwaysTemplate
                return AllOperativesViewModel(title: localized(optionValues.title),
                                              type: option,
                                              viewType: option.getViewType(),
                                              entity: .cardsActions,
                                              action: action,
                                              isDisabled: false,
                                              renderingMode: renderingMode)
            }
        }
        
        if let getPGFrequentOperativeOption = self.dependenciesResolver.resolve(forOptionalType: GetGPCardsOperativeOptionProtocol.self) {
            let types = getPGFrequentOperativeOption.getAllCardsOperativeActionType()
            let allActions: [AllOperativesViewModel] = types.compactMap { (type) in
                if let action = actions.first(where: {$0.type as? CardOperativeActionType == type}) {
                    return action
                } else {
                    return nil
                }
            }
            return allActions
        } else {
            return actions
        }
    }
}

public enum CardOperativeActionType {
    case onCard
    case offCard
    case instantCash
    case changePaymentMethod
    case delayPayment
    case payOff
    case pin
    case cvv
    case withdrawMoneyWithCode
    case applePay
    case block
    case mobileTopUp
    case ces
    case pdfExtract
    case modifyLimits
    case solidarityRounding
    case hireCard
    case changeAlias
    case settingsAlerts
    case subcriptions
    case custom(OperativeActionValues)

    public func values() -> (title: String, imageName: String) {
        let values: [CardOperativeActionType: (String, String)] = [
            .onCard: ("cardsOption_button_turnOn", "icnOn"),
            .offCard: ("cardsOption_button_turnOff", "icnOff"),
            .instantCash: ("transaction_buttonOption_directMoney", "icnInstantCash"),
            .delayPayment: ("cardsOption_button_delayPayment", "icnDelayReceipt"),
            .payOff: ("cardsOption_button_cardEntry", "icnDepositCard"),
            .pin: ("cardsOption_button_pin", "icnPin"),
            .cvv: ("cardsOption_button_cvv", "oneIcnCvv"),
            .block: ("cardsOption_button_block", "icnBlockCard"),
            .mobileTopUp: ("cardsOption_button_movilCharge", "icnMobileRechange"),
            .ces: ("cardsOption_button_ces", "icnMoreHighElectronic"),
            .pdfExtract: ("cardsOption_button_pdf", "icnExtract"),
            .modifyLimits: ("cardsOption_button_modifyCard", "icnChangeLimits"),
            .solidarityRounding: ("cardsOption_button_solidary", "icnSolidary"),
            .changePaymentMethod: ("cardsOption_button_changeWayToPay", "icnChangeWayToPay"),
            .hireCard: ("cardsOption_button_contractCards", "icnContract"),
            .applePay: ("cardsOption_button_addApple", "icnApay"),
            .changeAlias: ("cardsOption_button_changeAlias", "icnChangeAlias"),
            .settingsAlerts: ("cardsOption_button_settingAlerts", "icnAlertConfig"),
            .withdrawMoneyWithCode: ("cardsOption_button_codeMoney", "icnGetMoneyMobile"),
            .subcriptions: ("pg_button_m4m", "icnM4M")
        ]
        return values[self] ?? ("", "")
    }
    
    func getViewType() -> ActionButtonFillViewType {
        let optionValues = self.values()
        switch self {
        case let .custom(values):
            return .defaultButton(DefaultActionButtonViewModel(title: values.localizedKey,
                                                               imageKey: values.icon,
                                                               renderingMode: values.renderingMode,
                                                               titleAccessibilityIdentifier: values.identifier,
                                                               imageAccessibilityIdentifier: values.icon))
        default:
            return .defaultButton(DefaultActionButtonViewModel(title: optionValues.title,
                                                               imageKey: optionValues.imageName,
                                                               titleAccessibilityIdentifier: "",
                                                               imageAccessibilityIdentifier: optionValues.imageName))
        }
    }
}

extension CardOperativeActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
    }
    
    public static func == (lhs: CardOperativeActionType, rhs: CardOperativeActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension CardOperativeActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .onCard:
            return AccessibilityOtherOperatives.btnCardOn.rawValue
        case .offCard:
            return AccessibilityOtherOperatives.btnCardOff.rawValue
        case .instantCash:
            return AccessibilityOtherOperatives.btnDirectMoney.rawValue
        case .changePaymentMethod:
            return AccessibilityOtherOperatives.btnChangeWayToPay.rawValue
        case .delayPayment:
            return AccessibilityOtherOperatives.btnDelayPay.rawValue
        case .payOff:
            return AccessibilityOtherOperatives.btnCardEntry.rawValue
        case .pin:
            return AccessibilityOtherOperatives.btnPin.rawValue
        case .cvv:
            return AccessibilityOtherOperatives.btnCvv.rawValue
        case .withdrawMoneyWithCode:
            return AccessibilityOtherOperatives.btnCodeMoney.rawValue
        case .applePay:
            return AccessibilityOtherOperatives.btnAddApplePay.rawValue
        case .block:
            return AccessibilityOtherOperatives.btnBlockCard.rawValue
        case .mobileTopUp:
            return AccessibilityOtherOperatives.btnMobileRecharge.rawValue
        case .ces:
            return AccessibilityOtherOperatives.btnicnMoreHighElectronic.rawValue
        case .pdfExtract:
            return AccessibilityOtherOperatives.btnPdf.rawValue
        case .modifyLimits:
            return AccessibilityOtherOperatives.btnModifyLimits.rawValue
        case .solidarityRounding:
            return AccessibilityOtherOperatives.btnSolidary.rawValue
        case .hireCard:
            return AccessibilityOtherOperatives.btnContractCard.rawValue
        case .changeAlias:
            return AccessibilityOtherOperatives.btnChangeAliasCard.rawValue
        case .settingsAlerts:
            return AccessibilityOtherOperatives.btnalertConfigCard.rawValue
        case .subcriptions:
            return AccessibilityOtherOperatives.subscriptions.rawValue
        case let .custom(values):
            return values.identifier
        }
    }
}

extension CardOperativeActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .onCard:
            return "encender_tarjeta"
        case .offCard:
            return "apagar_tarjeta"
        case .instantCash:
            return "efectivo_instante"
        case .changePaymentMethod:
            return "forma_pago"
        case .delayPayment:
            return "retrasar_recibo"
        case .payOff:
            return "ingreso_tarjeta"
        case .pin:
            return "pin"
        case .cvv:
            return "cvv"
        case .withdrawMoneyWithCode:
            return "sacar_dinero_codigo"
        case .applePay:
            return "añadir_wallet"
        case .block:
            return "bloquear_tarjeta"
        case .mobileTopUp:
            return "recarga_movil"
        case .ces:
            return "alta_ces"
        case .pdfExtract:
            return "consultar_extracto"
        case .modifyLimits:
            return "modificar_limites"
        case .solidarityRounding:
            return "redondeo_solidario"
        case .hireCard:
            return "contratar_tarjetas"
        case .changeAlias:
            return "cambio_alias"
        case .settingsAlerts:
            return "configurar_alertas"
        case .subcriptions:
            return "subcriptions"
        case let .custom(values):
            return values.identifier
        }
    }
}
