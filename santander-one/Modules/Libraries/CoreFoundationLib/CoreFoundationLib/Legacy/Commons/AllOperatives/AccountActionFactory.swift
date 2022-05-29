//
//  AccountActionFactory.swift
//  Commons
//
//  Created by David Gálvez Alonso on 10/02/2020.
//

import Foundation

public class AccountActionFactory {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func getAccountOperativesButtons(isSmartGP: Bool,
                                            action: ((Any, AllOperatives) -> Void)?,
                                            enabledActions: [AccountOperativeActionTypeProtocol]? = []) -> [AllOperativesViewModel] {
        guard let enabledActions = enabledActions else {
            return []
        }
        let actions: [AllOperativesViewModel] = enabledActions.map { (option) in
            if let optionToEnum = AccountOperativeActionType(rawValue: option.rawValue) {
                switch optionToEnum {
                case .transfer:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .internalTransfer:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .favoriteTransfer:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .donation:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .fxPay:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .payBill:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .payTax:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .changeDirectDebit:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .cancelDirectDebit:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .foreignExchange:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .contractAccounts:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .changeAlias:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .settingsAlerts:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .certificateOfOwnership:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .transferOfContracts:
                    return otherOption(option: optionToEnum, isSmartGP: isSmartGP, action: action)
                case .custom(let values):
                    return customOption(option: optionToEnum, values: values, isSmartGP: isSmartGP, action: action)
                }
            } else if option.rawValue == "custom", let option = option as? AccountOperativeActionType, case .custom(let values) = option {
                return customOption(option: option, values: values, isSmartGP: isSmartGP, action: action)
            } else {
                return otherOption(option: option, isSmartGP: isSmartGP, action: action)
            }
        }
        if let getPGFrequentOperativeOption = self.dependenciesResolver.resolve(forOptionalType: GetGPAccountOperativeOptionProtocol.self) {
            return self.returnCountryActions(getPGFrequentOperativeOption: getPGFrequentOperativeOption, actions: actions)
        } else {
            return actions
        }
    }
    
    func allActions() -> [AccountOperativeActionType] {
        return [.transfer,
                .internalTransfer,
                .favoriteTransfer,
                .donation,
                .fxPay,
                .payBill,
                .payTax,
                .changeDirectDebit,
                .cancelDirectDebit,
                .foreignExchange,
                .contractAccounts,
                .changeAlias,
                .settingsAlerts,
                .certificateOfOwnership
        ]
    }
    
    func otherOption(option: AccountOperativeActionType,
                     isSmartGP: Bool, 
                     action: ((Any, AllOperatives) -> Void)?) -> AllOperativesViewModel {
        let optionValues = option.values()
        return AllOperativesViewModel(
            title: localized(optionValues.title),
            type: option,
            viewType: option.getViewType(isSmartGP: isSmartGP),
            entity: .accountActions,
            action: action,
            isDisabled: false,
            highlightedInfo: nil)
    }
    
    func otherOption(option: AccountOperativeActionTypeProtocol,
                     isSmartGP: Bool,
                     action: ((Any, AllOperatives) -> Void)?) -> AllOperativesViewModel {
        let optionValues = option.values()
        return AllOperativesViewModel(
            title: localized(optionValues.title),
            type: option,
            viewType: option.getViewType(isSmartGP: isSmartGP),
            entity: .accountActions,
            action: action,
            isDisabled: false,
            highlightedInfo: nil)
    }
    
    func customOption(option: AccountOperativeActionType,
                      values: OperativeActionValues, 
                      isSmartGP: Bool, 
                      action: ((Any, AllOperatives) -> Void)?) -> AllOperativesViewModel { 
        return AllOperativesViewModel(
            title: localized(values.localizedKey),
            type: option,
            viewType: option.getViewType(isSmartGP: isSmartGP),
            entity: .accountActions,
            action: action,
            isDisabled: values.isDisabled,
            highlightedInfo: nil)
    }
}

public enum AccountOperativeActionType {
    case transfer
    case internalTransfer
    case favoriteTransfer
    case donation
    case fxPay
    case payBill
    case payTax
    case changeDirectDebit
    case cancelDirectDebit
    case foreignExchange
    case contractAccounts
    case changeAlias
    case settingsAlerts
    case certificateOfOwnership
    case transferOfContracts
    case custom(OperativeActionValues)
    
    init?(rawValue: String, operativeActionValues: OperativeActionValues? = nil) {
        switch rawValue {
        case AccountOperativeActionType.transfer.rawValue: self = AccountOperativeActionType.transfer
        case AccountOperativeActionType.internalTransfer.rawValue: self = AccountOperativeActionType.internalTransfer
        case AccountOperativeActionType.favoriteTransfer.rawValue: self = AccountOperativeActionType.favoriteTransfer
        case AccountOperativeActionType.donation.rawValue: self = AccountOperativeActionType.donation
        case AccountOperativeActionType.fxPay.rawValue: self = AccountOperativeActionType.fxPay
        case AccountOperativeActionType.payBill.rawValue: self = AccountOperativeActionType.payBill
        case AccountOperativeActionType.payTax.rawValue: self = AccountOperativeActionType.payTax
        case AccountOperativeActionType.changeDirectDebit.rawValue: self = AccountOperativeActionType.changeDirectDebit
        case AccountOperativeActionType.cancelDirectDebit.rawValue: self = AccountOperativeActionType.cancelDirectDebit
        case AccountOperativeActionType.foreignExchange.rawValue: self = AccountOperativeActionType.foreignExchange
        case AccountOperativeActionType.contractAccounts.rawValue: self = AccountOperativeActionType.contractAccounts
        case AccountOperativeActionType.changeAlias.rawValue: self = AccountOperativeActionType.changeAlias
        case AccountOperativeActionType.settingsAlerts.rawValue: self = AccountOperativeActionType.settingsAlerts
        case AccountOperativeActionType.certificateOfOwnership.rawValue: self = AccountOperativeActionType.certificateOfOwnership
        case "custom":
            guard let operativeActionValues = operativeActionValues else { return nil }
            self = AccountOperativeActionType.custom(operativeActionValues)
        default: return nil
        }
    }

    public func values() -> (title: String, imageName: String) {
        let values: [AccountOperativeActionType: (String, String)] = [
             .transfer: ("accountOption_button_transfer", "icnSendMoney"),
             .internalTransfer: ("accountOption_button_transferAccount", "icnTransferAccounts"),
             .favoriteTransfer: ("accountOption_button_sendFavorite", "icnSendToFavourite"),
             .fxPay: ("accountOption_button_onePay", "icnOnePayFx"),
             .payBill: ("accountOption_button_payReceipt", "icnPayReceipt"),
             .payTax: ("accountOption_button_payTaxes", "icnPayTax"),
             .foreignExchange: ("accountOption_button_solidary", "icnRequestForeignCurrency"),
             .changeDirectDebit: ("accountOption_button_changeDirectDebit", "icnChangeDomicileReceipt"),
             .cancelDirectDebit: ("accountOption_button_cancelReceipt", "icnCancelReceipt"),
             .donation: ("accountOption_button_donations", "icnDonations"),
             .contractAccounts: ("accountOption_button_contractAccounts", "icnContract"),
             .changeAlias: ("accountOption_button_changeAlias", "icnChangeAlias"),
             .settingsAlerts: ("accountOption_button_settingAlerts", "icnAlertConfig"),
             .certificateOfOwnership: ("accountOption_button_certificateOfOwnership", "icnCertificate"),
             .transferOfContracts: ("accountOption_button_transferOfContracts", "icnTransferContract")
        ]
        return values[self] ?? ("", "")
    }
    
    public func getViewType(isSmartGP: Bool) -> ActionButtonFillViewType {
        let optionValues = self.values()
        switch self {
        case let .custom(values):
            return .defaultButton(DefaultActionButtonViewModel(title: values.localizedKey,
                                                               imageKey: values.icon,
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

private extension AccountActionFactory {
    func returnCountryActions(getPGFrequentOperativeOption: GetGPAccountOperativeOptionProtocol, actions: [AllOperativesViewModel]) -> [AllOperativesViewModel] {
        let types = getPGFrequentOperativeOption.getAllAccountOperativeActionType()
        let allActions: [AllOperativesViewModel] = types.compactMap { type in
            if let action = actions.first(where: {
                self.shouldIncludeAction(action: $0, type: type)
            }) {
                return action
            }
            return nil
        }
        return allActions
    }
    
    func shouldIncludeAction(action: AllOperativesViewModel, type: AccountOperativeActionTypeProtocol) -> Bool {
        if let currentType = action.type as? AccountOperativeActionType,
           currentType == AccountOperativeActionType(rawValue: type.rawValue) {
            return true
        } else if let currentType = action.type as? AccountOperativeActionTypeProtocol,
                  currentType.trackName == type.trackName {
            return true
        }
        return false
    }
}

extension AccountOperativeActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
    }
    
    public static func == (lhs: AccountOperativeActionType, rhs: AccountOperativeActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension AccountOperativeActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .transfer:
            return AccessibilityOtherOperatives.btnSendMoney.rawValue
        case .internalTransfer:
            return AccessibilityOtherOperatives.btnTransfer.rawValue
        case .favoriteTransfer:
            return AccessibilityOtherOperatives.btnSendToFavourite.rawValue
        case .donation:
            return AccessibilityOtherOperatives.btnDonation.rawValue
        case .fxPay:
            return AccessibilityOtherOperatives.btnOnePayFx.rawValue
        case .payBill:
            return AccessibilityOtherOperatives.btnPayReceipt.rawValue
        case .payTax:
            return AccessibilityOtherOperatives.btnPayTax.rawValue
        case .changeDirectDebit:
            return AccessibilityOtherOperatives.btnChangeDomicileReceipt.rawValue
        case .cancelDirectDebit:
            return AccessibilityOtherOperatives.btnCancelReceipt.rawValue
        case .foreignExchange:
            return AccessibilityOtherOperatives.btnRequestForeignCurrency.rawValue
        case .contractAccounts:
            return AccessibilityOtherOperatives.btnContractAccount.rawValue
        case .changeAlias:
            return AccessibilityOtherOperatives.btnChangeAliasAccount.rawValue
        case .settingsAlerts:
            return AccessibilityOtherOperatives.btnalertConfigAccount.rawValue
        case .certificateOfOwnership:
            return AccessibilityOtherOperatives.btnRequestCertificate.rawValue
        case .transferOfContracts:
            return AccessibilityOtherOperatives.btnTransferContract.rawValue
        case let .custom(values):
            return values.identifier
        }
    }
}

extension AccountOperativeActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .transfer:
            return "enviar_dinero"
        case .internalTransfer:
            return "traspaso"
        case .favoriteTransfer:
            return "enviar_favorito"
        case .donation:
            return "donacion"
        case .fxPay:
            return "pay_fx"
        case .payBill:
            return "pagar_recibo"
        case .payTax:
            return "pagar_impuesto"
        case .changeDirectDebit:
            return "cambiar_domiciliacion"
        case .cancelDirectDebit:
            return "anular_recibo"
        case .foreignExchange:
            return "moneda_extranjera"
        case .contractAccounts:
            return "contratar_cuentas"
        case .changeAlias:
            return "cambiar_alias"
        case .settingsAlerts:
            return "configurar_alertas"
        case .certificateOfOwnership:
            return "certificado_titularidad"
        case .transferOfContracts:
            return "trasnferencia_de_contratos"
        case let .custom(values):
            return values.identifier
        }
    }
}

extension AccountOperativeActionType: AccountOperativeActionTypeProtocol {
    public var rawValue: String {
        switch self {
        case .transfer: return "transfer"
        case .internalTransfer: return "internalTransfer"
        case .favoriteTransfer: return "favoriteTransfer"
        case .donation: return "donation"
        case .fxPay: return "fxPay"
        case .payBill: return "payBill"
        case .payTax: return "payTax"
        case .changeDirectDebit: return "changeDirectDebit"
        case .cancelDirectDebit: return "cancelDirectDebit"
        case .foreignExchange: return "foreignExchange"
        case .contractAccounts: return "contractAccounts"
        case .changeAlias: return "changeAlias"
        case .settingsAlerts: return "settingsAlerts"
        case .certificateOfOwnership: return "certificateOfOwnership"
        case .transferOfContracts: return "transferOfContracts"
        case .custom: return "custom"
        }
    }
    
    public func getAction() -> AccountOperativeAction {
        return .core(option: self)
    }
}

public protocol GetGPAccountOperativeOptionProtocol {
    func getAllAccountOperativeActionType() -> [AccountOperativeActionTypeProtocol]
    func getCountryAccountOperativeActionType(accounts: [AccountEntity]) -> [AccountOperativeActionTypeProtocol]
}

public protocol AccountOperativeActionTypeProtocol: AccessibilityProtocol, Trackable {
    var rawValue: String { get }
    func values() -> (title: String, imageName: String)
    func getViewType(isSmartGP: Bool) -> ActionButtonFillViewType
    func getAction() -> AccountOperativeAction
}

public enum AccountOperativeAction {
    case core(option: AccountOperativeActionType)
    case custom(action: () -> Void)
}

public protocol GetGPCardsOperativeOptionProtocol {
    func getAllCardsOperativeActionType() -> [CardOperativeActionType]
    func getCountryCardsOperativeActionType(cards: [CardEntity]) -> [CardOperativeActionType]
    func isOtherOperativeEnabled(_ option: CardOperativeActionType) -> Bool
}

public protocol GetGPLoanOperativeOptionProtocol {
    func getAllLoanOperativeActionType() -> [LoanActionType]
    func getCountryLoanOperativeActionType(loans: [LoanEntity]) -> [LoanActionType]
    func isOtherOperativeEnabled(_ option: LoanActionType) -> Bool
}

public protocol GetGPInvestmentFundOperativeOptionProtocol {
    func getAllFundOperativeActionType() -> [FundActionType]
    func getCountryFundOperativeActionType(fund: [FundEntity]) -> [FundActionType]
    func isOtherOperativeEnabled(_ option: FundActionType) -> Bool
}

public protocol GetGPPensionOperativeOptionProtocol {
    func getAllPensionOperativeActionType() -> [PensionActionType]
    func getCountryPensionOperativeActionType(pensions: [PensionEntity]) -> [PensionActionType]
    func isOtherOperativeEnabled(_ option: PensionActionType) -> Bool
}

public protocol GetGPInsuranceProtectionOperativeOptionProtocol {
    func getAllInsuranceProtectionOperativeActionType() -> [InsuranceProtectionActionType]
    func getCountryInsuranceProtectionOperativeActionType(insuranceProtections: [InsuranceProtectionEntity]) -> [InsuranceProtectionActionType]
}

public protocol GetGPOtherOperativeOptionProtocol {
    func getAllOtherOperativeActionType() -> [OtherActionType]
    func getCountryOtherOperativeActionType() -> [OtherActionType]
}

final public class OperativeActionValues {
    public let identifier: String
    public let isDisabled: Bool
    public let location: String?
    public let localizedKey: String
    public let icon: String
    public let renderingMode: UIImage.RenderingMode

    public init(identifier: String, localizedKey: String, icon: String, isDisabled: Bool, location: String? = nil, renderingMode: UIImage.RenderingMode = .alwaysTemplate) {
        self.identifier = identifier
        self.isDisabled = isDisabled
        self.location = location
        self.localizedKey = localizedKey
        self.icon = icon
        self.renderingMode = renderingMode
    }
}
