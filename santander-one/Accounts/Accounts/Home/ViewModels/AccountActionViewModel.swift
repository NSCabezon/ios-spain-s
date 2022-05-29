//
//  AccountActionViewModel.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import Foundation
import CoreFoundationLib
import UI

public enum AccountActionType {
    case transfer
    case billsAndTaxes
    case requestMoney
    case internalTransfer
    case favoriteTransfer
    case fxPay(OfferEntity?)
    case payBill
    case payTax
    case returnBill
    case foreignExchange(OfferEntity?)
    case changeDomicileReceipt
    case cancelBill
    case donation(OfferEntity?)
    case accountDetail
    case historicalEmitted
    case one(OfferEntity?)
    case contractAccount(PullOfferLocation?)
    case ownershipCertificate(OfferEntity?)
    case correosCash(OfferEntity?)
    case receiptFinancing(OfferEntity?)
    case automaticOperations(OfferEntity?)
    case custome(identifier: String, accesibilityIdentifier: String, trackName: String, localizedKey: String, icon: String, renderingMode: UIImage.RenderingMode = .alwaysTemplate, accesibilityButtonIdentifier: String? = nil)
    
    func values() -> AccountActionValues {
        switch self {
        case .transfer: return AccountActionValues(title: "accountOption_button_transfer", imageName: "icnSendMoney")
        case .billsAndTaxes: return AccountActionValues(title: "accountOption_button_billsTaxs", imageName: "icnBills")
        case .requestMoney: return AccountActionValues(title: "cardsOption_button_delayPayment", imageName: "icnDelayReceipt")
        case .internalTransfer: return AccountActionValues(title: "accountOption_button_transferAccount", imageName: "icnTransferAccounts")
        case .favoriteTransfer: return AccountActionValues(title: "accountOption_button_sendFavorite", imageName: "icnSendToFavourite")
        case .fxPay: return AccountActionValues(title: "accountOption_button_onePay", imageName: "icnOnePayFx")
        case .payBill: return AccountActionValues(title: "accountOption_button_payReceipt", imageName: "icnPayReceipt")
        case .payTax: return AccountActionValues(title: "accountOption_button_payTaxes", imageName: "icnPayTax")
        case .returnBill: return AccountActionValues(title: "accountOption_button_returnedReceipt", imageName: "icnReturnedReceipt")
        case .foreignExchange: return AccountActionValues(title: "accountOption_button_solidary", imageName: "icnForeignCurrency")
        case .changeDomicileReceipt: return AccountActionValues(title: "accountOption_button_changeDirectDebit", imageName: "icnChangeDomicileReceipt")
        case .cancelBill: return AccountActionValues(title: "accountOption_button_cancelReceipt", imageName: "icnCancelReceipt")
        case .donation: return AccountActionValues(title: "accountOption_button_donations", imageName: "icnDonations")
        case .accountDetail: return AccountActionValues(title: "accountOption_button_detail", imageName: "icnDetail")
        case .historicalEmitted: return AccountActionValues(title: "accountOption_button_historyTransfer", imageName: "icnHistoryTransfer")
        case .one: return AccountActionValues(title: "accountOption_button_one", imageName: "icnOne")
        case .contractAccount: return AccountActionValues(title: "accountOption_button_account", imageName: "icnContract")
        case .ownershipCertificate: return AccountActionValues(title: "accountOption_button_certificateOfOwnership", imageName: "icnCertificate")
        case .correosCash: return AccountActionValues(title: "accountOption_button_correosCash", imageName: "icnCorreosCash")
        case .receiptFinancing: return AccountActionValues(title: "accountOptions_button_financingOfReceipts", imageName: "icnFinancingOfReceipts")
        case .automaticOperations: return AccountActionValues(title: "accountOption_button_automaticOperations", imageName: "icnAutomaticOperations")
        case let .custome(_, _, _, localizedKey, icon, renderingMode, accesibilityButtonIdentifier): return AccountActionValues(title: localizedKey, imageName: icon, renderingMode: renderingMode, accesibilityValue: accesibilityButtonIdentifier)
        }
    }
    
    func getViewType() -> ActionButtonFillViewType {
        let optionValues = self.values()
        return .defaultButton(
            DefaultActionButtonViewModel(
                title: optionValues.title,
                imageKey: optionValues.imageName,
                renderingMode: optionValues.renderingMode,
                titleAccessibilityIdentifier: self.titleAccessibilityIdentifier ?? "",
                imageAccessibilityIdentifier: optionValues.imageName,
                accessibilityButtonValue: optionValues.accesibilityValue
            )
        )
    }
}

extension AccountActionType: AccessibilityProtocol {
    public var titleAccessibilityIdentifier: String? {
        switch self {
        case .transfer:
            return AccesibilityAccountsHomeAction.accountsHomeLabelTransfer
        case .internalTransfer:
            return AccesibilityAccountsHomeAction.accountsHomeLabelInternalTransfer
        case .favoriteTransfer:
            return AccesibilityAccountsHomeAction.accountsHomeLabelFavoriteTransfer
        case .donation:
            return AccesibilityAccountsHomeAction.accountsHomeLabelDonation
        case .requestMoney:
            return AccesibilityAccountsHomeAction.accountsHomeLabelRequestMoney
        case .fxPay:
            return AccesibilityAccountsHomeAction.accountsHomeLabelFxPay
        case .payBill:
            return AccesibilityAccountsHomeAction.accountsHomeLabelPayBill
        case .payTax:
            return AccesibilityAccountsHomeAction.accountsHomeLabelPayTax
        case .foreignExchange:
            return AccesibilityAccountsHomeAction.accountsHomeLabelForeignExchange
        case .billsAndTaxes:
            return AccesibilityAccountsHomeAction.accountsHomeLabelBillsAndTaxes
        case .returnBill:
            return AccesibilityAccountsHomeAction.accountsHomeLabelReturnBill
        case .cancelBill:
            return AccesibilityAccountsHomeAction.accountsHomeLabelCancelBill
        case .accountDetail:
            return AccesibilityAccountsHomeAction.accountsHomeLabelAccountDetail
        case .one:
            return AccesibilityAccountsHomeAction.accountsHomeLabelOne
        case .ownershipCertificate:
            return AccesibilityAccountsHomeAction.accountsHomeLabelOwnershipCertificate
        case .changeDomicileReceipt:
            return AccesibilityAccountsHomeAction.accountsHomeLabelChangeDomicileReceipt
        case .contractAccount:
            return AccesibilityAccountsHomeAction.accountsHomeLabelContractAccount
        case .historicalEmitted:
            return AccesibilityAccountsHomeAction.accountsHomeLabelHistoricalEmitted
        case .correosCash:
            return AccesibilityAccountsHomeAction.accountsHomeLabelCorreosCash
        case .receiptFinancing:
            return AccesibilityAccountsHomeAction.accountsLabelReceiptFinancing
        case .automaticOperations:
            return AccesibilityAccountsHomeAction.accountsHomeLabelAutomaticOperations
        case let .custome(_, accesibilityIdentifier, _, _, _, _, _):
            return accesibilityIdentifier
        }
    }

    public var accessibilityIdentifier: String? {
        switch self {
        case .transfer:
            return AccesibilityAccountsHomeAction.accountsHomeBtnTransfer
        case .internalTransfer:
            return AccesibilityAccountsHomeAction.accountsHomeBtnInternalTransfer
        case .favoriteTransfer:
            return AccesibilityAccountsHomeAction.accountsHomeBtnFavoriteTransfer
        case .donation:
            return AccesibilityAccountsHomeAction.accountsHomeBtnDonation
        case .requestMoney:
            return AccesibilityAccountsHomeAction.accountsHomeBtnRequestMoney
        case .fxPay:
            return AccesibilityAccountsHomeAction.accountsHomeBtnFxPay
        case .payBill:
            return AccesibilityAccountsHomeAction.accountsHomeBtnPayBill
        case .payTax:
            return AccesibilityAccountsHomeAction.accountsHomeBtnPayTax
        case .foreignExchange:
            return AccesibilityAccountsHomeAction.accountsHomeBtnForeignExchange
        case .billsAndTaxes:
            return AccesibilityAccountsHomeAction.accountsHomeBtnBillsAndTaxes
        case .returnBill:
            return AccesibilityAccountsHomeAction.accountsHomeBtnReturnBill
        case .cancelBill:
            return AccesibilityAccountsHomeAction.accountsHomeBtnCancelBill
        case .accountDetail:
            return AccesibilityAccountsHomeAction.accountsHomeBtnAccountDetail
        case .one:
            return AccesibilityAccountsHomeAction.accountsHomeBtnOne
        case .ownershipCertificate:
            return AccesibilityAccountsHomeAction.accountsHomeBtnOwnershipCertificate
        case .changeDomicileReceipt:
            return AccesibilityAccountsHomeAction.accountsHomeBtnChangeDomicileReceipt
        case .contractAccount:
            return AccesibilityAccountsHomeAction.accountsHomeBtnContractAccount
        case .historicalEmitted:
            return AccesibilityAccountsHomeAction.accountsHomeBtnHistoricalEmitted
        case .correosCash:
            return AccesibilityAccountsHomeAction.accountsHomeBtnCorreosCash
        case .receiptFinancing:
            return AccesibilityAccountsHomeAction.accountsReceiptFinancing
        case .automaticOperations:
            return AccesibilityAccountsHomeAction.accountsHomeAutomaticOperations
        case let .custome(_, accesibilityIdentifier, _, _, _, _, _):
            return accesibilityIdentifier
        }
    }
}

extension AccountActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .transfer: return "enviar_dinero"
        case .billsAndTaxes: return "recibos"
        case .requestMoney: return "pedir_dinero"
        case .internalTransfer: return "traspaso"
        case .favoriteTransfer: return "enviar_favorito"
        case .fxPay: return "envio_one_pay_fx"
        case .payBill: return "pagar_recibo"
        case .payTax: return "pagar_impuesto"
        case .returnBill: return "devolver_recibo"
        case .foreignExchange: return "moneda_extranjera"
        case .changeDomicileReceipt: return "cambiar_domiciliacion"
        case .cancelBill: return "anular_recibo"
        case .donation: return "hacer_una_donacion"
        case .accountDetail: return "detalle_cuenta"
        case .historicalEmitted: return "historico_envios"
        case .one: return "santander_one"
        case .contractAccount: return "una_cuenta"
        case .ownershipCertificate: return "certificado_titularidad"
        case .correosCash: return nil
        case .receiptFinancing: return nil
        case .automaticOperations: return nil
        case let .custome(_, _, trackName, _, _, _, _): return trackName
        }
    }
}

struct AccountActionValues {
    let title: String
    let imageName: String
    let renderingMode: UIImage.RenderingMode
    let accesibilityValue: String?

    init(title: String, imageName: String, renderingMode: UIImage.RenderingMode = .alwaysTemplate, accesibilityValue: String? = nil) {
        self.title = title
        self.imageName = imageName
        self.renderingMode = renderingMode
        self.accesibilityValue = accesibilityValue
    }
}

struct AccountActionViewModel {
    let type: AccountActionType
    let viewType: ActionButtonFillViewType
    let entity: AccountEntity
    let isDisabled: Bool
    let highlightedInfo: HighlightedInfo?
    let action: ((AccountActionType, AccountEntity) -> Void)?
    let isDragDisabled: Bool
    let renderingMode: UIImage.RenderingMode
    var accessibilityIdentifier: String? {
        return type.accessibilityIdentifier
    }
        
    init(type: AccountActionType,
         viewType: ActionButtonFillViewType? = nil,
         entity: AccountEntity,
         isDisabled: Bool = false,
         imageUrl: String? = nil,
         highlightedInfo: HighlightedInfo? = nil,
         action: ((AccountActionType, AccountEntity) -> Void)?,
         isDragDisabled: Bool = false,
         renderingMode: UIImage.RenderingMode = .alwaysTemplate) {
        self.type = type
        self.viewType = viewType ?? type.getViewType()
        self.entity = entity
        self.isDisabled = isDisabled
        self.highlightedInfo = highlightedInfo
        self.action = action
        self.isDragDisabled = isDragDisabled
        self.renderingMode = renderingMode
    }
}

extension AccountActionViewModel: ActionButtonViewModelProtocol {
    var actionType: AccountActionType {
        return type
    }
}

extension AccountActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
        hasher.combine(self.values().title)
        hasher.combine(self.values().imageName)
    }
    public static func == (lhs: AccountActionType, rhs: AccountActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

func ~= (values: [AccountActionType], rhs: AccountActionType) -> Bool {
    return values.contains(rhs)
}
