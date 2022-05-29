////
////  CardActionType.swift
////  Pods
////
////  Created by Hernán Villamil on 22/4/22.

import Foundation
import CoreFoundationLib
import CoreDomain
import UI

// swiftlint:disable cyclomatic_complexity
public enum CardActionType {
    case enable
    case onCard
    case offCard
    case instantCash
    case delayPayment
    case payOff
    case chargeDischarge
    case pin
    case cvv
    case detail
    case block
    case withdrawMoneyWithCode
    case mobileTopUp
    case ces
    case pdfExtract
    case historicPdfExtract
    case pdfDetail
    case fractionablePurchases
    case modifyLimits
    case solidarityRounding(OfferRepresentable?)
    case changePaymentMethod
    case hireCard(PullOfferLocationRepresentable?)
    case divide(SplitableExpenseProtocol?)
    case share(Shareable?)
    case fraud(OfferRepresentable?)
    case chargePrepaid
    case applePay
    case duplicateCard
    case suscription(OfferRepresentable?)
    case configure
    case subscriptions
    case financingBills(OfferRepresentable?)
    case custom(CustomCardActionValues)
    func values() -> (title: String, imageName: String) {
        switch self {
        case .enable: return ("cardsOption_button_activate", "icnActivate")
        case .onCard: return ("cardsOption_button_turnOn", "icnOn")
        case .offCard: return ("cardsOption_button_turnOff", "icnOff")
        case .instantCash: return ("cardsOption_button_directMoney", "icnInstantCash")
        case .delayPayment: return ("cardsOption_button_delayReceipt", "icnDelayReceipt")
        case .payOff: return ("cardsOption_button_cardEntry", "icnDepositCard")
        case .chargeDischarge: return ("cardsOption_button_chargeDischarge", "icnChargeDischarge")
        case .pin: return ("cardsOption_button_pin", "icnPin")
        case .cvv: return ("cardsOption_button_cvv", "oneIcnCvv")
        case .detail: return ("cardsOption_button_cardDetail", "icnDetail")
        case .block: return ("cardsOption_button_block", "icnBlockCard")
        case .withdrawMoneyWithCode: return ("cardsOption_button_codeWithdraw", "icnWithdrawMobile")
        case .mobileTopUp: return ("cardsOption_button_movilCharge", "icnMobileRechange")
        case .ces: return ("cardsOption_button_ces", "icnCES")
        case .pdfExtract: return ("cardsOption_button_pdf", "icnExtract")
        case .fractionablePurchases: return ("cardsOption_button_fractionablePurchases", "icnFractionablePurchases")
        case .historicPdfExtract: return ("cardsOption_button_statementHistory", "icnStatementHistory")
        case .pdfDetail: return ("transaction_buttonOption_viewPdf", "icnPdf")
        case .modifyLimits: return ("cardsOption_button_modifyCard", "icnChangeLimits")
        case .solidarityRounding: return ("cardsOption_button_solidary", "icnSolidary")
        case .changePaymentMethod: return ("cardsOption_button_changeWayToPay", "icnChangeWayToPay")
        case .hireCard: return ("cardsOption_button_contractCards", "icnContract")
        case .applePay: return ("cardsOption_button_addApple", "icnApay")
        case .duplicateCard: return ("cardsOption_button_duplicate", "icnDuplicateCard")
        case .suscription: return ("cardsOption_button_subscriptions", "icnSubscriptionCards")
        case .chargePrepaid: return ("transaction_buttonOption_chargeCard", "icnUploadDownload")
        case .divide: return ("cardsOption_button_expensesDivide", "icnDivide")
        case .share: return ("generic_button_share", "icnShare")
        case .fraud: return ("transaction_buttonOption_fraud", "icnFraud")
        case .configure: return ("cardsOption_button_customizeCard", "icnCustomizeCard")
        case .subscriptions: return ("pg_button_m4m", "icnM4M")
        case .financingBills: return ("cardsOption_button_financingOfReceipts", "icnFinancingOfReceipts")
        case let .custom(values): return (values.localizedKey, values.icon)
        }
    }
    
    func getViewType(_ renderingMode: UIImage.RenderingMode = .alwaysTemplate) -> ActionButtonFillViewType {
        let optionValues = self.values()
        return .defaultButton(DefaultActionButtonViewModel(title: optionValues.title,
                                                           imageKey: optionValues.imageName,
                                                           renderingMode: renderingMode,
                                                           titleAccessibilityIdentifier: "",
                                                           imageAccessibilityIdentifier: optionValues.imageName))
    }
}

extension CardActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .enable:
            return AccesibilityCardsHomeAction.cardsHomeBtnActivate
        case .onCard:
            return AccesibilityCardsHomeAction.cardsHomeBtnOn
        case .offCard:
            return AccesibilityCardsHomeAction.cardsHomeBtnOff
        case .instantCash:
            return AccesibilityCardsHomeAction.cardsHomeBtnInstantCash
        case .changePaymentMethod:
            return AccesibilityCardsHomeAction.cardsHomeBtnChangePaymentMethod
        case .delayPayment:
            return AccesibilityCardsHomeAction.cardsHomeBtnDelayPayment
        case .payOff:
            return AccesibilityCardsHomeAction.cardsHomeBtnPayOff
        case .pin:
            return AccesibilityCardsHomeAction.cardsHomeBtnPin
        case .cvv:
            return AccesibilityCardsHomeAction.cardsHomeBtnCvv
        case .withdrawMoneyWithCode:
            return AccesibilityCardsHomeAction.cardsHomeBtnWithdrawMoneyWithCode
        case .applePay:
            return AccesibilityCardsHomeAction.cardsHomeBtnApplePay
        case .block:
            return AccesibilityCardsHomeAction.cardsHomeBtnBlock
        case .mobileTopUp:
            return AccesibilityCardsHomeAction.cardsHomeBtnMobileTopUp
        case .ces:
            return AccesibilityCardsHomeAction.cardsHomeBtnCes
        case .pdfExtract:
            return AccesibilityCardsHomeAction.cardsHomeBtnPdfExtract
        case .pdfDetail:
            return AccesibilityCardsHomeAction.cardsHomePDFDetail
        case .fractionablePurchases:
            return AccesibilityCardsHomeAction.cardsOptionBtnFractionablePurchases
        case .historicPdfExtract:
            return AccesibilityCardsHomeAction.cardsOptionBtnStatementHistory
        case .modifyLimits:
            return AccesibilityCardsHomeAction.cardsHomeBtnModifyLimits
        case .solidarityRounding:
            return AccesibilityCardsHomeAction.cardsHomeBtnSolidarityRounding
        case .hireCard:
            return AccesibilityCardsHomeAction.cardsHomeBtnHireCard
        case .chargeDischarge:
            return AccesibilityCardsHomeAction.cardsHomeBtnChargeDischarge
        case .detail:
            return AccesibilityCardsHomeAction.cardsHomeBtnDetail
        case .divide:
            return AccesibilityCardsHomeAction.cardsHomeBtnDivide
        case .share:
            return AccesibilityCardsHomeAction.cardsHomeBtnShare
        case .fraud:
            return AccesibilityCardsHomeAction.cardsHomeBtnFraud
        case .chargePrepaid:
            return AccesibilityCardsHomeAction.cardsHomeBtnChargePrepaid
        case .duplicateCard:
            return AccesibilityCardsHomeAction.cardsHomeBtnDuplicateCard
        case .suscription:
            return AccesibilityCardsHomeAction.cardsHomeBtnSuscription
        case .configure:
            return AccesibilityCardsHomeAction.cardsHomeBtnConfigure
        case .subscriptions:
            return AccesibilityCardsHomeAction.cardsOptionsBtnSubscriptions
        case .financingBills:
            return AccesibilityCardsHomeAction.cardsOptionBtnFinancingOfReceipts
        case let .custom(values):
            return values.identifier
        }
    }
}

extension CardActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .enable:
            return "activar_tarjeta"
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
        case .historicPdfExtract:
            return "extracto_pdf"
        case .fractionablePurchases:
            return "compras_fraccionadas"
        case .modifyLimits:
            return "modificar_limites"
        case .solidarityRounding:
            return "redondeo_solidario"
        case .hireCard:
            return "contratar_tarjetas"
        case .chargeDischarge:
            return "carga_descarga"
        case .detail:
            return "detalle_tarjeta"
        case .divide:
            return "dividir_gasto"
        case .share:
            return "compartir"
        case .fraud:
            return "fraude"
        case .chargePrepaid:
            return "carga_descarga"
        case .duplicateCard:
            return "duplicar_tarjeta"
        case .suscription:
            return "suscripciones_en_tarjetas"
        case .configure:
            return "configurar_tarjeta"
        case .subscriptions:
            return "subscripciones"
        case .financingBills:
            return "financiacion_recibos"
        case .pdfDetail:
            return "detalle_transaccion_pdf"
        case let .custom(values):
            return values.identifier
        }
    }
}

extension CardActionType {
    func getCoordinator(dependencies: CardExternalDependenciesResolver) -> BindableCoordinator {
        switch self {
        case .enable:
            return dependencies.cardActivateCoordinator()
        case .onCard:
            return dependencies.cardOnCoordinator()
        case .offCard:
            return dependencies.cardOffCoordinator()
        case .instantCash:
            return dependencies.cardInstantCashCoordinator()
        case .delayPayment:
            return dependencies.cardDelayPaymentCoordinator()
        case .payOff:
            return dependencies.cardPayOffCoordinator()
        case .chargeDischarge:
            return dependencies.cardChargeDischargeCoordinator()
        case .pin:
            return dependencies.cardPinCoordinator()
        case .cvv:
            return dependencies.cardCVVCoordinator()
        case .detail:
            return dependencies.cardActivateCoordinator() // update this
        case .block:
            return dependencies.cardBlockCoordinator()
        case .withdrawMoneyWithCode:
            return dependencies.cardWithdrawMoneyWithCodeCoordinator()
        case .mobileTopUp:
            return dependencies.cardMobileTopUpCoordinator()
        case .ces:
            return dependencies.cardCesCoordinator()
        case .pdfExtract:
            return dependencies.cardPdfExtractCoordinator()
        case .historicPdfExtract:
            return dependencies.cardHistoricPdfExtractCoordinator()
        case .pdfDetail:
            return dependencies.cardPdfDetailCoordinator()
        case .fractionablePurchases:
            return dependencies.cardFractionablePurchasesCoordinator()
        case .modifyLimits:
            return dependencies.cardModifyLimitsCoordinator()
        case .solidarityRounding:
            return dependencies.cardSolidarityRoundingCoordinator()
        case .changePaymentMethod:
            return dependencies.cardChangePaymentMethodCoordinator()
        case .hireCard:
            return dependencies.cardHireCoordinator()
        case .divide:
            return dependencies.cardDivideCoordinator()
        case .share:
            return dependencies.cardShareCoordinator()
        case .fraud:
            return dependencies.cardFraudCoordinator()
        case .chargePrepaid:
            return dependencies.cardChargePrepaidCoordinator()
        case .applePay:
            return dependencies.cardApplePayCoordinator()
        case .duplicateCard:
            return dependencies.cardDuplicatedCoordinator()
        case .suscription:
            return dependencies.cardSuscriptionCoordinator()
        case .configure:
            return dependencies.cardConfigureCoordinator()
        case .subscriptions:
            return dependencies.cardSubscriptionsCoordinator()
        case .financingBills:
            return dependencies.cardFinancingBillsCoordinator()
        case .custom:
            return dependencies.cardCustomeCoordinator()
        }
    }
}

// swiftlint:enable cyclomatic_complexity
extension CardActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
    }
    
    public static func == (lhs: CardActionType, rhs: CardActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Legay: remove when posssible.
public enum OldCardActionType {
    case enable
    case onCard
    case offCard
    case instantCash
    case delayPayment
    case payOff
    case chargeDischarge
    case pin
    case cvv
    case detail
    case block
    case withdrawMoneyWithCode
    case mobileTopUp
    case ces
    case pdfExtract
    case historicPdfExtract
    case pdfDetail
    case fractionablePurchases
    case modifyLimits
    case solidarityRounding(OfferEntity?)
    case changePaymentMethod
    case hireCard(PullOfferLocation?)
    case divide(SplitableExpenseProtocol)
    case share(Shareable?)
    case fraud(OfferEntity?)
    case chargePrepaid
    case applePay
    case duplicateCard
    case suscription(OfferEntity?)
    case configure
    case custome(CustomCardActionValues)
    case subscriptions
    case financingBills(OfferEntity?)
    // swiftlint:disable cyclomatic_complexity
    func values() -> (title: String, imageName: String) {
        switch self {
        case .enable: return ("cardsOption_button_activate", "icnActivate")
        case .onCard: return ("cardsOption_button_turnOn", "icnOn")
        case .offCard: return ("cardsOption_button_turnOff", "icnOff")
        case .instantCash: return ("cardsOption_button_directMoney", "icnInstantCash")
        case .delayPayment: return ("cardsOption_button_delayReceipt", "icnDelayReceipt")
        case .payOff: return ("cardsOption_button_cardEntry", "icnDepositCard")
        case .chargeDischarge: return ("cardsOption_button_chargeDischarge", "icnChargeDischarge")
        case .pin: return ("cardsOption_button_pin", "icnPin")
        case .cvv: return ("cardsOption_button_cvv", "oneIcnCvv")
        case .detail: return ("cardsOption_button_cardDetail", "icnDetail")
        case .block: return ("cardsOption_button_block", "icnBlockCard")
        case .withdrawMoneyWithCode: return ("cardsOption_button_codeWithdraw", "icnWithdrawMobile")
        case .mobileTopUp: return ("cardsOption_button_movilCharge", "icnMobileRechange")
        case .ces: return ("cardsOption_button_ces", "icnCES")
        case .pdfExtract: return ("cardsOption_button_pdf", "icnExtract")
        case .fractionablePurchases: return ("cardsOption_button_fractionablePurchases", "icnFractionablePurchases")
        case .historicPdfExtract: return ("cardsOption_button_statementHistory", "icnStatementHistory")
        case .pdfDetail: return ("transaction_buttonOption_viewPdf", "icnPdf")
        case .modifyLimits: return ("cardsOption_button_modifyCard", "icnChangeLimits")
        case .solidarityRounding: return ("cardsOption_button_solidary", "icnSolidary")
        case .changePaymentMethod: return ("cardsOption_button_changeWayToPay", "icnChangeWayToPay")
        case .hireCard: return ("cardsOption_button_contractCards", "icnContract")
        case .applePay: return ("cardsOption_button_addApple", "icnApay")
        case .duplicateCard: return ("cardsOption_button_duplicate", "icnDuplicateCard")
        case .suscription: return ("cardsOption_button_subscriptions", "icnSubscriptionCards")
        case .chargePrepaid: return ("transaction_buttonOption_chargeCard", "icnUploadDownload")
        case .divide: return ("cardsOption_button_expensesDivide", "icnDivide")
        case .share: return ("generic_button_share", "icnShare")
        case .fraud: return ("transaction_buttonOption_fraud", "icnFraud")
        case .configure: return ("cardsOption_button_customizeCard", "icnCustomizeCard")
        case let .custome(values): return (values.localizedKey, values.icon)
        case .subscriptions: return ("pg_button_m4m", "icnM4M")
        case .financingBills: return ("cardsOption_button_financingOfReceipts", "icnFinancingOfReceipts")
        }
    }
    // swiftlint:enable cyclomatic_complexity
    
    func getViewType(_ renderingMode: UIImage.RenderingMode = .alwaysTemplate) -> ActionButtonFillViewType {
        let optionValues = self.values()
        return .defaultButton(DefaultActionButtonViewModel(title: optionValues.title,
                                                           imageKey: optionValues.imageName,
                                                           renderingMode: renderingMode,
                                                           titleAccessibilityIdentifier: "\(self.accessibilityIdentifier ?? "cardActionButton")_title",
                                                           imageAccessibilityIdentifier: optionValues.imageName))
    }
}

extension OldCardActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .enable:
            return AccesibilityCardsHomeAction.cardsHomeBtnActivate
        case .onCard:
            return AccesibilityCardsHomeAction.cardsHomeBtnOn
        case .offCard:
            return AccesibilityCardsHomeAction.cardsHomeBtnOff
        case .instantCash:
            return AccesibilityCardsHomeAction.cardsHomeBtnInstantCash
        case .changePaymentMethod:
            return AccesibilityCardsHomeAction.cardsHomeBtnChangePaymentMethod
        case .delayPayment:
            return AccesibilityCardsHomeAction.cardsHomeBtnDelayPayment
        case .payOff:
            return AccesibilityCardsHomeAction.cardsHomeBtnPayOff
        case .pin:
            return AccesibilityCardsHomeAction.cardsHomeBtnPin
        case .cvv:
            return AccesibilityCardsHomeAction.cardsHomeBtnCvv
        case .withdrawMoneyWithCode:
            return AccesibilityCardsHomeAction.cardsHomeBtnWithdrawMoneyWithCode
        case .applePay:
            return AccesibilityCardsHomeAction.cardsHomeBtnApplePay
        case .block:
            return AccesibilityCardsHomeAction.cardsHomeBtnBlock
        case .mobileTopUp:
            return AccesibilityCardsHomeAction.cardsHomeBtnMobileTopUp
        case .ces:
            return AccesibilityCardsHomeAction.cardsHomeBtnCes
        case .pdfExtract:
            return AccesibilityCardsHomeAction.cardsHomeBtnPdfExtract
        case .pdfDetail:
            return AccesibilityCardsHomeAction.cardsHomePDFDetail
        case .fractionablePurchases:
            return AccesibilityCardsHomeAction.cardsOptionBtnFractionablePurchases
        case .historicPdfExtract:
            return AccesibilityCardsHomeAction.cardsOptionBtnStatementHistory
        case .modifyLimits:
            return AccesibilityCardsHomeAction.cardsHomeBtnModifyLimits
        case .solidarityRounding:
            return AccesibilityCardsHomeAction.cardsHomeBtnSolidarityRounding
        case .hireCard:
            return AccesibilityCardsHomeAction.cardsHomeBtnHireCard
        case .chargeDischarge:
            return AccesibilityCardsHomeAction.cardsHomeBtnChargeDischarge
        case .detail:
            return AccesibilityCardsHomeAction.cardsHomeBtnDetail
        case .divide:
            return AccesibilityCardsHomeAction.cardsHomeBtnDivide
        case .share:
            return AccesibilityCardsHomeAction.cardsHomeBtnShare
        case .fraud:
            return AccesibilityCardsHomeAction.cardsHomeBtnFraud
        case .chargePrepaid:
            return AccesibilityCardsHomeAction.cardsHomeBtnChargePrepaid
        case .duplicateCard:
            return AccesibilityCardsHomeAction.cardsHomeBtnDuplicateCard
        case .suscription:
            return AccesibilityCardsHomeAction.cardsHomeBtnSuscription
        case .configure:
            return AccesibilityCardsHomeAction.cardsHomeBtnConfigure
        case let .custome(values):
            return values.identifier
        case .subscriptions:
            return AccesibilityCardsHomeAction.cardsOptionsBtnSubscriptions
        case .financingBills:
            return AccesibilityCardsHomeAction.cardsOptionBtnFinancingOfReceipts
        }
    }
}

extension OldCardActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .enable:
            return "activar_tarjeta"
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
        case .historicPdfExtract:
            return "extracto_pdf"
        case .fractionablePurchases:
            return "compras_fraccionadas"
        case .modifyLimits:
            return "modificar_limites"
        case .solidarityRounding:
            return "redondeo_solidario"
        case .hireCard:
            return "contratar_tarjetas"
        case .chargeDischarge:
            return "carga_descarga"
        case .detail:
            return "detalle_tarjeta"
        case .divide:
            return "dividir_gasto"
        case .share:
            return "compartir"
        case .fraud:
            return "fraude"
        case .chargePrepaid:
            return "carga_descarga"
        case .duplicateCard:
            return "duplicar_tarjeta"
        case .suscription:
            return "suscripciones_en_tarjetas"
        case .configure:
            return "configurar_tarjeta"
        case let .custome(values): return values.identifier
        case .subscriptions:
            return "subscripciones"
        case .financingBills:
            return "financiacion_recibos"
        case .pdfDetail:
            return "detalle_transaccion_pdf"
        }
    }
}
