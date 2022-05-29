import CoreFoundationLib

enum TransactionCategory: String, CaseIterable {
    case salaries = "Nóminas"
    case settlements = "Nóminas Liquidaciones"
    case assistance = "Servicios sociales, ayudas y pensiones"
    case home = "Casa y Hogar"
    case transport = "Transporte y automoción"
    case shoppingAndFood = "Comercio y Tiendas"
    case leisure = "Ocio"
    case banksAndInsurance = "Bancos y seguros"
    case health = "Salud, Belleza y Bienestar"
    case taxes = "Impuestos y tasas"
    case atmsAndTrasfers = "Cajeros y transferencias"
    case tasks = "Gestiones personales y profesionales"
    case education = "Educación"
    case savings = "Ahorro e inversión"
    case none
    
    var iconName: String {
        switch self {
        case .salaries:
            return "icnPayrollCat"
        case .settlements:
            return "icnPayrollCat"
        case .assistance:
            return "icnHelpsCat"
        case .home:
            return "icnHomeCat"
        case .transport:
            return "icnTransportCat"
        case .shoppingAndFood:
            return "icnPurchasesAndFoodCat"
        case .leisure:
            return "icnLeisureCat"
        case .banksAndInsurance:
            return "icnBanksAndInsurancesCat"
        case .health:
            return "icnHealthCat"
        case .taxes:
            return "icnTaxesCat"
        case .atmsAndTrasfers:
            return "icnAtmsCat"
        case .tasks:
            return "icnManagementsCat"
        case .education:
            return "icnEducationCat"
        case .savings:
            return "icnSavingCat"
        case .none:
            return "icnOthersCat"
        }
    }
    
    var literalKey: String {
        switch self {
        case .salaries:
            return "categorization_label_payroll"
        case .settlements:
            return "categorization_label_payroll"
        case .assistance:
            return "categorization_label_helps"
        case .home:
            return "categorization_label_home"
        case .transport:
            return "categorization_label_transport"
        case .shoppingAndFood:
            return "categorization_label_purchasesAndFood"
        case .leisure:
            return "categorization_label_leisure"
        case .banksAndInsurance:
            return "categorization_label_banksAndInsurances"
        case .health:
            return "categorization_label_health"
        case .taxes:
            return "categorization_label_taxes"
        case .atmsAndTrasfers:
            return "categorization_label_atms"
        case .tasks:
            return "categorization_label_managements"
        case .education:
            return "categorization_label_education"
        case .savings:
            return "categorization_label_saving"
        case .none:
            return "categorization_label_otherExpenses"
        }
    }
}

final class AccountTransactionDetailViewModel {
    
    let transaction: AccountTransactionEntity
    let account: AccountEntity
    let timeManager: TimeManager
    var detail: AccountTransactionDetailEntity?
    var error: String?
    var isEasyPayEnabled: Bool
    let isSplitExpensesEnabled: Bool
    let offerEntity: OfferEntity?
    // Ratio height / width for banner image. Calculate dynamically
    var offerRatio: CGFloat?
    var category: TransactionCategory?
    private let dependenciesResolver: DependenciesResolver
    
    init(transaction: AccountTransactionEntity,
         account: AccountEntity,
         error: String?,
         isEasyPayEnabled: Bool,
         isSplitExpensesEnabled: Bool,
         timeManager: TimeManager,
         offerEntity: OfferEntity? = nil,
         offerRatio: CGFloat? = nil,
         dependenciesResolver: DependenciesResolver) {
        self.transaction = transaction
        self.account = account
        self.timeManager = timeManager
        self.detail = nil
        self.error = error
        self.isEasyPayEnabled = isEasyPayEnabled
        self.isSplitExpensesEnabled = isSplitExpensesEnabled
        self.offerEntity = offerEntity
        self.offerRatio = offerRatio
        self.dependenciesResolver = dependenciesResolver
    }
    
    init(transaction: AccountTransactionEntity,
         account: AccountEntity,
         detail: AccountTransactionDetailEntity?,
         isEasyPayEnabled: Bool,
         isSplitExpensesEnabled: Bool,
         timeManager: TimeManager,
         offerEntity: OfferEntity? = nil,
         offerRatio: CGFloat? = nil,
         dependenciesResolver: DependenciesResolver) {
        self.transaction = transaction
        self.account = account
        self.timeManager = timeManager
        self.detail = detail
        self.error = nil
        self.isEasyPayEnabled = isEasyPayEnabled
        self.isSplitExpensesEnabled = isSplitExpensesEnabled
        self.offerEntity = offerEntity
        self.offerRatio = offerRatio
        self.dependenciesResolver = dependenciesResolver
    }
    
    var description: String {
        return transaction.alias?.capitalized ?? ""
    }
    
    var accountAlias: String {
        return account.alias ?? ""
    }
    
    var accountAmount: String {
        return transaction.balance?.getStringValueWithoutMillion() ?? ""
    }
    
    var formattedAmount: NSAttributedString? {
        guard let amount = transaction.amount else { return nil }
        let font = UIFont.santander(family: .text, type: .bold, size: 32)
        let moneyDecorator = MoneyDecorator(amount, font: font)
        return moneyDecorator.formatAsMillions()
    }
    
    var operationDate: String? {
        return timeManager.toString(date: transaction.operationDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
    
    var valueDate: String? {
        return timeManager.toString(date: transaction.valueDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
    
    var info: [(String, String)] {
        return detail?.literals ?? []
    }
    
    var isPiggyBankAccount: Bool {
        return account.isPiggyBankAccount
    }
    
    var isTransactionNegative: Bool {
        guard let amount = self.amount.value else {
            return false
        }
        return amount < 0
    }
    
    var isSplitExpensesOperativeEnabled: Bool {
        return self.isTransactionNegative && self.isSplitExpensesEnabled
    }
    
    var accountTransactionDetailModifier: AccountTransactionDetailActionModifierProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: AccountTransactionDetailActionModifierProtocol.self)
    }
    
    var customeActionModifier: AccountTransactionDetailCustomActionModifierProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: AccountTransactionDetailCustomActionModifierProtocol.self)
    }

    var customActions: [AccountTransactionDetailAction]? {
        return self.dependenciesResolver.resolve(forOptionalType: AccountTransactionDetailActionProtocol.self)?.getTransactionActions(for: transaction)
    }

    var isVisibleBalanceExtraInfo: Bool {
        return self.dependenciesResolver.resolve(forOptionalType: AccountTransactionDetailProtocol.self)?.isVisibleBalanceExtraInfo ?? true
    }
}

extension AccountTransactionDetailViewModel: SplitableExpenseProtocol {
    var amount: AmountEntity {
        return self.transaction.amount ?? AmountEntity(value: 0)
    }
    
    var concept: String {
        return self.transaction.description ?? self.description
    }
    
    var productAlias: String {
        return self.accountAlias
    }
}

extension AccountTransactionDetailViewModel: Equatable {
    
    static func == (lhs: AccountTransactionDetailViewModel, rhs: AccountTransactionDetailViewModel) -> Bool {
        return lhs.transaction == rhs.transaction
    }
}

extension AccountTransactionDetailViewModel: Shareable {
    
    func getShareableInfo() -> String {
        if let accountTransactionDetailShareableInfo: AccountTransactionDetailShareableInfoProtocol = self.dependenciesResolver.resolve(forOptionalType: AccountTransactionDetailShareableInfoProtocol.self) {
            return accountTransactionDetailShareableInfo.getShareableInfo(
                description: description,
                alias: self.accountAlias,
                amount: formattedAmount,
                info: info,
                operationDate: operationDate,
                valueDate: valueDate
            )
        }
        return AccountTransactionDetailStringBuilder()
            .add(description: description)
            .add(amount: formattedAmount)
            .add(operationDate: operationDate)
            .add(valueDate: valueDate)
            .add(info: info)
            .build()
    }
}
