//
//  AllOperativesActionFactory.swift
//  Commons
//
//  Created by David Gálvez Alonso on 10/02/2020.
//


public class AllOperativesActionFactory {
    let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func getAllOperativesButtons(isSmartGP: Bool, action: ((Any, AllOperatives) -> Void)?, enabledActions: [AllOperatives: Any], originalImages: [AllOperatives: Any]?) -> [([AllOperativesViewModel], String)] {
        var allValues = [([AllOperativesViewModel], String)]()
        let accountsActions: [AllOperativesViewModel] = AccountActionFactory(dependenciesResolver: self.dependenciesResolver).getAccountOperativesButtons(isSmartGP: isSmartGP, action: action, enabledActions: enabledActions[.accountActions] as? [AccountOperativeActionTypeProtocol])
        allValues.append((accountsActions, "operate_title_account"))
        
        let cardsActions: [AllOperativesViewModel] = CardActionFactory(dependenciesResolver: self.dependenciesResolver).getCardOperativesButtons(action: action, enabledActions: enabledActions[.cardsActions] as? [CardOperativeActionType], originalImages: originalImages?[.cardsActions] as? [CardOperativeActionType])
        allValues.append((cardsActions, "operate_title_card"))
        
        let stockActions: [AllOperativesViewModel] = StocksActionFactory.getStocksOperativesButtons(action: action, enabledActions: enabledActions[.stocksActions] as? [StocksActionType])
        allValues.append((stockActions, "operate_title_Values"))
        
        let loansActions: [AllOperativesViewModel] = LoanActionFactory(dependenciesResolver: dependenciesResolver).getLoanOperativesButtons(action: action, enabledActions: enabledActions[.loanActions] as? [LoanActionType])
        allValues.append((loansActions, "operate_title_loans"))
        
        let pensionActions: [AllOperativesViewModel] = PensionActionFactory(dependenciesResolver: dependenciesResolver).getPensionOperativesButtons(action: action, enabledActions: enabledActions[.pensionActions] as? [PensionActionType])
        allValues.append((pensionActions, "operate_title_pensionPlan"))
        
        let fundsActions: [AllOperativesViewModel] = FundActionFactory(dependenciesResolver: dependenciesResolver).getFundOperativesButtons(action: action, enabledActions: enabledActions[.fundActions] as? [FundActionType])
        allValues.append((fundsActions, "operate_title_funds"))
        
        let insuranceActions: [AllOperativesViewModel] = InsuranceActionFactory.getInsuranceOperativesButtons(action: action, enabledActions: enabledActions[.insuranceActions] as? [InsuranceActionType])
        allValues.append((insuranceActions, "operate_title_insurance"))
        
        let insuranceProtectionActions: [AllOperativesViewModel] = InsuranceProtectionActionFactory(dependenciesResolver: dependenciesResolver).getInsuranceOperativesButtons(action: action, enabledActions: enabledActions[.insuranceProtectionActions] as? [InsuranceProtectionActionType])
        allValues.append((insuranceProtectionActions, "operate_title_protection"))
        
        let otherActions: [AllOperativesViewModel] = OtherActionFactory(dependenciesResolver: dependenciesResolver).getOtherOperativesButtons(action: action, enabledActions: enabledActions[.otherActions] as? [OtherActionType])
        allValues.append((otherActions, "operate_title_others"))
        
        return allValues
    }
    
    public func getFilteredOperativesButtons(isSmartGP: Bool,
                                             containingText text: String,
                                             action: ((Any, AllOperatives) -> Void)?,
                                             enabledActions: [AllOperatives: Any],
                                             originalImages: [AllOperatives: Any]?,
                                             operativeOnShorcutsAppKeywords: [OperativeOnShortcutsKeywordsEntity]) -> [AllOperativesViewModel] {
        // Get Actions
        var accountsActions = AccountActionFactory(dependenciesResolver: self.dependenciesResolver)
            .getAccountOperativesButtons(
                isSmartGP: isSmartGP, action: action,
                enabledActions: enabledActions[.accountActions] as? [AccountOperativeActionTypeProtocol]
            )
        var cardsActions = CardActionFactory(dependenciesResolver: dependenciesResolver)
            .getCardOperativesButtons(
                action: action,
                enabledActions: enabledActions[.cardsActions] as? [CardOperativeActionType],
                originalImages: originalImages?[.cardsActions] as? [CardOperativeActionType]
            )
        var stockActions = StocksActionFactory
            .getStocksOperativesButtons(
                action: action,
                enabledActions: enabledActions[.stocksActions] as? [StocksActionType]
            )
        var loansActions = LoanActionFactory(dependenciesResolver: self.dependenciesResolver)
            .getLoanOperativesButtons(
                action: action,
                enabledActions: enabledActions[.loanActions] as? [LoanActionType]
            )
        var pensionActions = PensionActionFactory(dependenciesResolver: self.dependenciesResolver)
            .getPensionOperativesButtons(
                action: action,
                enabledActions: enabledActions[.pensionActions] as? [PensionActionType]
            )
        var fundsActions = FundActionFactory(dependenciesResolver: self.dependenciesResolver)
            .getFundOperativesButtons(
                action: action,
                enabledActions: enabledActions[.fundActions] as? [FundActionType]
            )
        var insuranceActions = InsuranceActionFactory
            .getInsuranceOperativesButtons(
                action: action,
                enabledActions: enabledActions[.insuranceActions] as? [InsuranceActionType]
            )
        var insuranceProtectionActions = InsuranceProtectionActionFactory(dependenciesResolver: dependenciesResolver)
            .getInsuranceOperativesButtons(
                action: action,
                enabledActions: enabledActions[.insuranceProtectionActions] as? [InsuranceProtectionActionType]
            )
        var otherActions = OtherActionFactory(dependenciesResolver: dependenciesResolver)
            .getOtherOperativesButtons(
                action: action,
                enabledActions: enabledActions[.otherActions] as? [OtherActionType])
        // Get filtered keywords
        let filteredKeywords = filterKeywords(
            operativeOnShorcutsAppKeywords: operativeOnShorcutsAppKeywords,
            text: text
        )
        // Filter Actions
        accountsActions = filterActionsByKeywordsAndTitle(
            actions: accountsActions,
            filteredKeywords: filteredKeywords,
            text: text
        )
        cardsActions = filterActionsByKeywordsAndTitle(
            actions: cardsActions,
            filteredKeywords: filteredKeywords,
            text: text
        )
        stockActions = filterActionsByKeywordsAndTitle(
            actions: stockActions,
            filteredKeywords: filteredKeywords,
            text: text
        )
        loansActions = filterActionsByKeywordsAndTitle(
            actions: loansActions,
            filteredKeywords: filteredKeywords,
            text: text
        )
        pensionActions = filterActionsByKeywordsAndTitle(
            actions: pensionActions,
            filteredKeywords: filteredKeywords,
            text: text
        )
        fundsActions = filterActionsByKeywordsAndTitle(
            actions: fundsActions,
            filteredKeywords: filteredKeywords,
            text: text
        )
        insuranceActions = filterActionsByKeywordsAndTitle(
            actions: insuranceActions,
            filteredKeywords: filteredKeywords,
            text: text
        )
        insuranceProtectionActions = filterActionsByKeywordsAndTitle(
            actions: insuranceProtectionActions,
            filteredKeywords: filteredKeywords,
            text: text
        )
        otherActions = filterActionsByKeywordsAndTitle(
            actions: otherActions,
            filteredKeywords: filteredKeywords,
            text: text
        )
        // Set result
        return (
            accountsActions
                + cardsActions
                + stockActions
                + loansActions
                + pensionActions
                + fundsActions
                + insuranceActions
                + insuranceProtectionActions
                + otherActions
        )
    }
}

private extension AllOperativesActionFactory {
    func filterKeywords(operativeOnShorcutsAppKeywords: [OperativeOnShortcutsKeywordsEntity],
                        text: String) -> [String] {
        operativeOnShorcutsAppKeywords.compactMap { (item) -> String? in
            return !item.keywords.isEmpty && item.keywords
                .map({$0.lowercased().notWhitespaces()})
                .contains(text.lowercased().notWhitespaces())
                ? item.title
                : nil
        }
    }
    
    func filterActionsByKeywordsAndTitle(actions: [AllOperativesViewModel],
                                         filteredKeywords: [String],
                                         text: String) -> [AllOperativesViewModel] {
        let filteredByTitle = filterActionsByTitle(
            actions: actions,
            text: text
        )
        let filteredByKeywords = filterActionsByKeywords(
            filteredKeywords: filteredKeywords,
            actions: actions
        )
        return filteredByKeywords + filteredByTitle
    }
    
    func filterActionsByTitle(actions: [AllOperativesViewModel],
                              text: String) -> [AllOperativesViewModel] {
        return actions.filter({
            let filteredTitle = $0.title
                .lowercased()
                .replacingOccurrences(of: "\n", with: " ")
                .notWhitespaces()
            let searchText = text
                .lowercased()
                .replacingOccurrences(of: "\n", with: " ")
                .notWhitespaces()
            return filteredTitle.contains(searchText)
        })
    }
    
    func filterActionsByKeywords(filteredKeywords: [String],
                                 actions: [AllOperativesViewModel]) -> [AllOperativesViewModel] {
        var filteredActions = [AllOperativesViewModel]()
        filteredKeywords.forEach { keyword in
            actions.forEach { action in
                guard let filteredAction = action.compare(withKeywordTitle: keyword) else {
                    return
                }
                filteredActions.append(filteredAction)
            }
        }
        return filteredActions
    }
}

public enum AllOperatives: CaseIterable {
    case cardsActions
    case accountActions
    case stocksActions
    case loanActions
    case pensionActions
    case fundActions
    case insuranceActions
    case insuranceProtectionActions
    case otherActions
}

public class StocksActionFactory {
    public static func getStocksOperativesButtons(action: ((Any, AllOperatives) -> Void)?, enabledActions: [StocksActionType]?) -> [AllOperativesViewModel] {
        let actions: [AllOperativesViewModel] = StocksActionType.allCases.map { (option) in
            let optionValues = option.values()
            return AllOperativesViewModel(title: localized(optionValues.title),
                                          type: option,
                                          viewType: option.getViewType(),
                                          entity: .stocksActions,
                                          action: action,
                                          isDisabled: !(enabledActions?.contains(option) ?? false))
        }
        
        return actions
    }
}

public enum StocksActionType: String, CaseIterable {
    case buy
    case checkOrders
    
    public func values() -> (title: String, imageName: String) {
        let values: [StocksActionType: (String, String)] = [
            .buy: ("stocksOption_button_search", "icnBuyStock"),
            .checkOrders: ("stocksOption_button_checkOrders", "icnOrders")
        ]
        return values[self] ?? (self.rawValue, "")
    }
    
    func getViewType() -> ActionButtonFillViewType {
        let optionValues = self.values()
        return .defaultButton(DefaultActionButtonViewModel(title: optionValues.title,
                                                           imageKey: optionValues.imageName,
                                                           titleAccessibilityIdentifier: "",
                                                           imageAccessibilityIdentifier: optionValues.imageName))
    }
}

extension StocksActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .buy:
            return "contratar_valores"
        case .checkOrders:
            return "consulta_ordenes"
        }
    }
}

public class LoanActionFactory {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func getLoanOperativesButtons(action: ((Any, AllOperatives) -> Void)?, enabledActions: [LoanActionType]?) -> [AllOperativesViewModel] {
        guard let enabledActions = enabledActions else {
            return []
        }
        let actions: [AllOperativesViewModel] = enabledActions.map { (option) in
            switch option {
            case .custom(let values):
                return AllOperativesViewModel(
                    title: localized(values.localizedKey),
                    type: option,
                    viewType: option.getViewType(),
                    entity: .loanActions,
                    action: action,
                    isDisabled: false,
                    renderingMode: .alwaysOriginal
                )
            default:
                let optionValues = option.values()
                return AllOperativesViewModel(title: localized(optionValues.title),
                                              type: option,
                                              viewType: option.getViewType(),
                                              entity: .loanActions,
                                              action: action,
                                              isDisabled: false)
            }
        }
        if let getFrequentOperativeOption = self.dependenciesResolver.resolve(forOptionalType: GetGPLoanOperativeOptionProtocol.self) {
            let types = getFrequentOperativeOption.getAllLoanOperativeActionType()
            var allActions: [AllOperativesViewModel] = []
            types.forEach { (type) in
                if let action = actions.first(where: {$0.type as? LoanActionType == type}) {
                    allActions.append(action)
                }
            }
            return allActions
        } else {
            return actions
        }
    }
}

public enum LoanActionType {
    case partialAmortization
    case changeAccount
    case configureAlerts
    case custom(OperativeActionValues)
    
    public func values() -> (title: String, imageName: String) {
        let values: [LoanActionType: (String, String)] = [
            .partialAmortization: ("loansOption_button_anticipatedAmortization", "icnEarlyRepayment"),
            .changeAccount: ("loansOption_button_changeAccount", "icnChangeAccount"),
            .configureAlerts: ("loansOption_button_settingAlerts", "icnAlertConfig")
        ]
        return values[self] ?? ("", "")
    }
    
    func getViewType() -> ActionButtonFillViewType {
        let optionValues = self.values()
        switch self {
        case let .custom(values):
            return .defaultButton(
                DefaultActionButtonViewModel(
                    title: values.localizedKey,
                    imageKey: values.icon,
                    titleAccessibilityIdentifier: values.identifier,
                    imageAccessibilityIdentifier: values.icon
                )
            )
        default:
            return .defaultButton(DefaultActionButtonViewModel(title: optionValues.title,
                                                               imageKey: optionValues.imageName,
                                                               titleAccessibilityIdentifier: "",
                                                               imageAccessibilityIdentifier: optionValues.imageName))
        }
    }
}

extension LoanActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
    }
    
    public static func == (lhs: LoanActionType, rhs: LoanActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension LoanActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .partialAmortization:
            return "amortizacion_parcial"
        case .changeAccount:
            return "cambio_cuenta_cargo"
        case .configureAlerts:
            return "configurar_alertas"
        case let .custom(values):
            return values.identifier
        }
    }
}

// MARK: - Pension Action Factory
public class PensionActionFactory {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func getPensionOperativesButtons(action: ((Any, AllOperatives) -> Void)?, enabledActions: [PensionActionType]?) -> [AllOperativesViewModel] {
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
                                              renderingMode: .alwaysOriginal)
            default:
                let optionValues = option.values()
                return AllOperativesViewModel(title: localized(optionValues.title),
                                              type: option,
                                              viewType: option.getViewType(),
                                              entity: .pensionActions,
                                              action: action,
                                              isDisabled: false,
                                              renderingMode: .alwaysOriginal)
            }
        }
        if let getPGFrequentOperativeOption = self.dependenciesResolver.resolve(forOptionalType: GetGPPensionOperativeOptionProtocol.self) {
            let types = getPGFrequentOperativeOption.getAllPensionOperativeActionType()
            var allActions: [AllOperativesViewModel] = []
            types.forEach { (type) in
                if let action = actions.first(where: {$0.type as? PensionActionType == type}) {
                    allActions.append(action)
                }
            }
            return allActions
        } else {
            return actions
        }
    }
}

public enum PensionActionType {
    case extraordinaryContribution
    case periodicalContribution
    case custom(OperativeActionValues)
    
    public func values() -> (title: String, imageName: String) {
        let values: [PensionActionType: (String, String)] = [
            .extraordinaryContribution: ("plansOption_button_extraContribution", "icnContribution"),
            .periodicalContribution: ("plansOption_button_periodicContribution", "icnPeriodicAportation")
        ]
        return values[self] ?? ("", "")
    }
    
    func getViewType() -> ActionButtonFillViewType {
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

extension PensionActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .extraordinaryContribution:
            return "aportacion_extraordinaria_pensiones"
        case .periodicalContribution:
            return "aportacion_periodica_pensiones"
        case let .custom(values):
            return values.identifier
        }
    }
}

extension PensionActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
    }
    
    public static func == (lhs: PensionActionType, rhs: PensionActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Fund Action Factory

public class FundActionFactory {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func getFundOperativesButtons(action: ((Any, AllOperatives) -> Void)?, enabledActions: [FundActionType]?) -> [AllOperativesViewModel] {
        guard
            let enabledActions = enabledActions 
        else {
            return []
        }
        let actions: [AllOperativesViewModel] = enabledActions.map { (option) in
            switch option {
            case .custom(let values):
                return AllOperativesViewModel(
                    title: localized(values.localizedKey),
                    type: option,
                    viewType: option.getViewType(),
                    entity: .fundActions,
                    action: action,
                    isDisabled: false,
                    renderingMode: .alwaysOriginal)
            default:
                let optionValues = option.values()
                return AllOperativesViewModel(
                    title: localized(optionValues.title),
                    type: option,
                    viewType: option.getViewType(),
                    entity: .fundActions,
                    action: action,
                    isDisabled: false,
                    renderingMode: .alwaysOriginal)
            }
        }
        if let getPGFrequentOperativeOption = self.dependenciesResolver.resolve(forOptionalType: GetGPInvestmentFundOperativeOptionProtocol.self) {
            let types = getPGFrequentOperativeOption.getAllFundOperativeActionType()
            var allActions: [AllOperativesViewModel] = []
            types.forEach { (type) in  
                if let action = actions.first(where: {$0.type as? FundActionType == type}) {
                    allActions.append(action)
                }
            }
            return allActions
        } else {
            return actions
        }
    }
}

public enum FundActionType {
    case subscription
    case custom(OperativeActionValues)
    
    public func values() -> (title: String, imageName: String) {
        let values: [FundActionType: (String, String)] = [
            .subscription: ("fundsOption_button_subscription", "icnSubscription")
        ]
        return values[self] ?? ("", "")
    }
    
    func getViewType() -> ActionButtonFillViewType {
        let optionValues = self.values()
        switch self {
        case let .custom(values):
            return .defaultButton(DefaultActionButtonViewModel(
                                    title: values.localizedKey,
                                    imageKey: values.icon,
                                    titleAccessibilityIdentifier: values.identifier,
                                    imageAccessibilityIdentifier: values.icon))
        default:
            return .defaultButton(DefaultActionButtonViewModel(
                                    title: optionValues.title,
                                    imageKey: optionValues.imageName,
                                    titleAccessibilityIdentifier: "",
                                    imageAccessibilityIdentifier: optionValues.imageName))
        }
    }
}

extension FundActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .subscription:
            return "suscripcion"
        case let .custom(values):
            return values.identifier
        }
    }
}
extension FundActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
    }
    
    public static func == (lhs: FundActionType, rhs: FundActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Insurance Action Factory

public class InsuranceActionFactory {
    public static func getInsuranceOperativesButtons(action: ((Any, AllOperatives) -> Void)?, enabledActions: [InsuranceActionType]?) -> [AllOperativesViewModel] {
        let actions: [AllOperativesViewModel] = InsuranceActionType.allCases.map { (option) in
            let optionValues = option.values()
            return AllOperativesViewModel(title: localized(optionValues.title),
                                          type: option,
                                          viewType: option.getViewType(),
                                          entity: .insuranceActions,
                                          action: action,
                                          isDisabled: !(enabledActions?.contains(option) ?? false))
        }
        return actions
    }
}

public enum InsuranceActionType: String, CaseIterable {
    case extraordinaryContribution
    case changeRemittancePlan
    case activateRemittancePlan
    
    public func values() -> (title: String, imageName: String) {
        let values: [InsuranceActionType: (String, String)] = [
            .extraordinaryContribution: ("insurancesOption_buttom_extraContribution", "icnExtraAportation"),
            .changeRemittancePlan: ("insurancesOptions_buttom_changeRemittancePlan", "icnChangeAportation"),
            .activateRemittancePlan: ("insurancesOption_buttom_activateRemittancePlan", "icnArchive")
        ]
        return values[self] ?? (self.rawValue, "")
    }
    
    func getViewType() -> ActionButtonFillViewType {
        let optionValues = self.values()
        return .defaultButton(DefaultActionButtonViewModel(title: optionValues.title,
                                                           imageKey: optionValues.imageName,
                                                           titleAccessibilityIdentifier: "",
                                                           imageAccessibilityIdentifier: optionValues.imageName))
    }
}

extension InsuranceActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .extraordinaryContribution:
            return "aportacion_extraordinaria_seguro_ahorro"
        case .changeRemittancePlan:
            return "cambio_plan_aportacion"
        case .activateRemittancePlan:
            return "activar_plan_aportacion"
        }
    }
}

public class InsuranceProtectionActionFactory {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func getInsuranceOperativesButtons(action: ((Any, AllOperatives) -> Void)?, enabledActions: [InsuranceProtectionActionType]?) -> [AllOperativesViewModel] {
        var allInsuranceProtectionActions: [InsuranceProtectionActionType] = InsuranceProtectionActionType.allCases
        if let getPGFrequentOperativeOption = self.dependenciesResolver.resolve(forOptionalType: GetGPInsuranceProtectionOperativeOptionProtocol.self) {
            allInsuranceProtectionActions = getPGFrequentOperativeOption.getAllInsuranceProtectionOperativeActionType()
        }
        let actions: [AllOperativesViewModel] = allInsuranceProtectionActions.map { (option) in
            switch option {
            case .custom(let values):
                return AllOperativesViewModel(title: localized(values.localizedKey),
                                              type: option,
                                              viewType: option.getViewType(),
                                              entity: .insuranceProtectionActions,
                                              action: action,
                                              isDisabled: !(enabledActions?.contains(option) ?? false))
            default:
                let optionValues = option.values()
                return AllOperativesViewModel(title: localized(optionValues.title),
                                              type: option,
                                              viewType: option.getViewType(),
                                              entity: .insuranceProtectionActions,
                                              action: action,
                                              isDisabled: !(enabledActions?.contains(option) ?? false))
            }
        }
        return actions
    }
}

public class OtherActionFactory {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func getOtherOperativesButtons(action: ((Any, AllOperatives) -> Void)?, enabledActions: [OtherActionType]?) -> [AllOperativesViewModel] {
        var allOtherActions = OtherActionType.allCases
        if let getPGFrequentOperativeOption = self.dependenciesResolver.resolve(forOptionalType: GetGPOtherOperativeOptionProtocol.self) {
            allOtherActions = getPGFrequentOperativeOption.getAllOtherOperativeActionType()
        }
        let actions: [AllOperativesViewModel] = allOtherActions.map { (option) in
            switch option {
            case .custom(let values):
                return AllOperativesViewModel(title: localized(values.localizedKey),
                                              type: option,
                                              viewType: option.getViewType(),
                                              entity: .otherActions,
                                              action: action,
                                              isDisabled: !(enabledActions?.contains(option) ?? false))
            default:
                let optionValues = option.values()
                return AllOperativesViewModel(title: localized(optionValues.title),
                                              type: option,
                                              viewType: option.getViewType(),
                                              entity: .otherActions,
                                              action: action,
                                              isDisabled: !(enabledActions?.contains(option) ?? false))
            }
        }
        return actions
    }
}

public enum OtherActionType {
    case officeAppointment
    case custom(OperativeActionValues)
    
    public func values() -> (title: String, imageName: String) {
        let values: [OtherActionType: (String, String)] = [
            .officeAppointment: ("otherOption_button_appointmentInOffice", "icnCalendar")
        ]
        return values[self] ?? ("", "")
    }
    
    func getViewType() -> ActionButtonFillViewType {
        let optionValues = self.values()
        switch self {
        case let .custom(values):
            return .defaultButton(
                DefaultActionButtonViewModel(
                    title: values.localizedKey,
                    imageKey: values.icon,
                    titleAccessibilityIdentifier: values.identifier,
                    imageAccessibilityIdentifier: values.icon
                )
            )
        default:
            return .defaultButton(DefaultActionButtonViewModel(title: optionValues.title,
                                                               imageKey: optionValues.imageName,
                                                               titleAccessibilityIdentifier: "",
                                                               imageAccessibilityIdentifier: optionValues.imageName))
        }
    }
}

extension OtherActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
    }
    
    public static func == (lhs: OtherActionType, rhs: OtherActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension OtherActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .officeAppointment:
            return "others_office_appointment"
        case let .custom(values):
            return values.identifier
        }
    }
}

extension OtherActionType: CaseIterable {
    public static var allCases: [OtherActionType]  = [.officeAppointment]
}

public enum InsuranceProtectionActionType {
    case managePolicy
    case custom(OperativeActionValues)
    
    public func values() -> (title: String, imageName: String) {
        let values: [InsuranceProtectionActionType: (String, String)] = [
            .managePolicy: ("insurancesOption_button_myPolicy", "icnManagePolicy")
        ]
        return values[self] ?? ("", "")
    }
    
    public func getViewType() -> ActionButtonFillViewType {
        let optionValues = self.values()
        switch self {
        case let .custom(values):
            return .defaultButton(
                DefaultActionButtonViewModel(
                    title: values.localizedKey,
                    imageKey: values.icon,
                    titleAccessibilityIdentifier: values.identifier,
                    imageAccessibilityIdentifier: values.icon
                )
            )
        default:
            return .defaultButton(DefaultActionButtonViewModel(title: optionValues.title,
                                                               imageKey: optionValues.imageName,
                                                               titleAccessibilityIdentifier: "",
                                                               imageAccessibilityIdentifier: optionValues.imageName))
        }
    }
}

extension InsuranceProtectionActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
    }
    
    public static func == (lhs: InsuranceProtectionActionType, rhs: InsuranceProtectionActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension InsuranceProtectionActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .managePolicy:
            return "gestionar_poliza_seguro_proteccion"
        case let .custom(values):
            return values.identifier
        }
    }
}

extension InsuranceProtectionActionType: CaseIterable {
    public static var allCases: [InsuranceProtectionActionType]  = [.managePolicy]
}

public struct AllOperativesViewModel {
    public let title: String
    public let type: Any
    public let viewType: ActionButtonFillViewType
    public let action: ((Any, AllOperatives) -> Void)?
    public let isDisabled: Bool
    public let entity: AllOperatives
    public let highlightedInfo: HighlightedInfo?
    public let isDragDisabled: Bool
    public let renderingMode: UIImage.RenderingMode
    public var accessibilityIdentifier: String? {
        return (type as? AccessibilityProtocol)?.accessibilityIdentifier
    }
    
    init(title: String,
         type: Any,
         viewType: ActionButtonFillViewType,
         entity: AllOperatives,
         action: ((Any, AllOperatives) -> Void)?,
         isDisabled: Bool = false,
         highlightedInfo: HighlightedInfo? = nil,
         isDragDisabled: Bool = true,
         renderingMode: UIImage.RenderingMode = .alwaysTemplate) {
        self.title = title
        self.type = type
        self.viewType = viewType
        self.entity = entity
        self.action = action
        self.isDisabled = isDisabled
        self.highlightedInfo = highlightedInfo
        self.isDragDisabled = isDragDisabled
        self.renderingMode = renderingMode
    }
    
    public func compare(withKeywordTitle keywordTitle: String) -> AllOperativesViewModel? {
        let localKeywordTitle = keywordTitle
            .lowercased()
            .replacingOccurrences(of: "\n", with: " ")
            .notWhitespaces()
        let localTitle = self.title
            .lowercased()
            .replacingOccurrences(of: "\n", with: " ")
            .notWhitespaces()
        guard localKeywordTitle == localTitle else {
            return nil
        }
        return self
    }
}

extension AllOperativesViewModel: ActionButtonViewModelProtocol {
    public var actionType: Any {
        return type
    }
}

public protocol ActionButtonViewModelProtocol: ActionButtonFillViewModelProtocol, AccessibilityProtocol {
    associatedtype ActionType
    associatedtype Entity
    var actionType: ActionType { get }
    var entity: Entity { get }
    var highlightedInfo: HighlightedInfo? { get }
    var isDisabled: Bool { get }
    var action: ((ActionType, Entity) -> Void)? { get }
    var isDragDisabled: Bool { get }
    var renderingMode: UIImage.RenderingMode { get }
}

extension StocksActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .buy:
            return AccessibilityOtherOperatives.btnBuyValues.rawValue
        case .checkOrders:
            return AccessibilityOtherOperatives.btncheckOrders.rawValue
        }
    }
}

extension LoanActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .partialAmortization:
            return AccessibilityOtherOperatives.btnAmortizationPartial.rawValue
        case .changeAccount:
            return AccessibilityOtherOperatives.bntnChangeAccount.rawValue
        case .configureAlerts:
            return AccessibilityOtherOperatives.btnalertConfigLoan.rawValue
        case let .custom(values):
            return values.identifier
        }
    }
}

extension PensionActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .extraordinaryContribution:
            return AccessibilityOtherOperatives.btnExtraAportationPensionPlan.rawValue
        case .periodicalContribution:
            return AccessibilityOtherOperatives.btnPeriodicAportation.rawValue
        case let .custom(values):
            return values.identifier
        }
    }
}

extension FundActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .subscription:
            return AccessibilityOtherOperatives.btnSuscription.rawValue
        case let .custom(values):
            return values.identifier
        }
    }
}

extension InsuranceActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .extraordinaryContribution:
            return AccessibilityOtherOperatives.btnExtraAportationInsurance.rawValue
        case .changeRemittancePlan:
            return AccessibilityOtherOperatives.btnChangeAportation.rawValue
        case .activateRemittancePlan:
            return AccessibilityOtherOperatives.btnActiveAportation.rawValue
        }
    }
}

extension InsuranceProtectionActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .managePolicy:
            return AccessibilityOtherOperatives.btnManagePolicy.rawValue
        case let .custom(values):
            return values.identifier
        }
    }
}
