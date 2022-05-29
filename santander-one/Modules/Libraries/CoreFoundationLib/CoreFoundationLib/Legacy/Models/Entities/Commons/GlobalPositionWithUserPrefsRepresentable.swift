//
//  GlobalPosition.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 08/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public protocol GlobalPositionProduct {
    var isVisible: Bool { get set }
    var productId: String { get }
    var alias: String? { get }
    var productIdentifier: String { get }
}

public class GlobalPositionProductList<Product: GlobalPositionProduct> {
    private let products: [Product]
    
    public init(products: [Product]) {
        self.products = products
    }
    
    public func all() -> [Product] {
        return products
    }
    
    public func visibles() -> [Product] {
        return products.filter({ $0.isVisible })
    }

    public var notVisibles: [Product] {
        return products.filter({ !$0.isVisible })
    }
    
    @available(*, deprecated)
    public func totalOfVisibles(with value: KeyPath<Product, Decimal?>) -> Decimal {
        return visibles().reduce(0, { $0 + ($1[keyPath: value] ?? 0) })
    }
    
    @available(*, deprecated)
    public func totalOfVisibles(with value: KeyPath<Product, Decimal?>, where condition: (Product) -> Bool) -> Decimal {
        return visibles().filter(condition).reduce(0, { $0 + ($1[keyPath: value] ?? 0) })
    }
    
    public func totalOfVisibles(with value: KeyPath<Product, AmountDTO?>) -> Decimal {
        return visibles().reduce(0, {
            let amount = $1[keyPath: value]
            return $0 + (((amount?.currency?.currencyType == CoreCurrencyDefault.default) ? amount?.value: nil) ?? 0)
        })
    }
    
    public func totalOfVisibles(with value: KeyPath<Product, AmountDTO?>, where condition: (Product) -> Bool) -> Decimal {
        return visibles().filter(condition).reduce(0, {
            let amount = $1[keyPath: value]
            return $0 + (((amount?.currency?.currencyType == CoreCurrencyDefault.default) ? amount?.value: nil) ?? 0)
        })
    }
    
    public func totalOfVisibles(value: (Product) -> Decimal?, where condition: (Product) -> Bool) -> Decimal {
        return visibles().filter(condition).reduce(0, { $0 + (value($1) ?? 0) })
    }
    
    public func totalOfVisibles(value: (Product) -> Decimal?) -> Decimal {
        return visibles().reduce(0, { $0 + (value($1) ?? 0) })
    }
    
    public func firstSorted(by keyPath: KeyPath<Product, Decimal?>, where filter: (Product) -> Bool = { _ in return true }) -> Decimal {
        let total = visibles()
            .filter(filter)
            .sorted(by: { $0[keyPath: keyPath] ?? 0 > $1[keyPath: keyPath] ?? 0 })
            .first?[keyPath: keyPath]
        return total ?? 0
    }
    
    public func lastSorted(by keyPath: KeyPath<Product, Decimal?>, where filter: (Product) -> Bool = { _ in return true }) -> Decimal {
        let total = visibles()
            .filter(filter)
            .sorted(by: { $0[keyPath: keyPath] ?? 0 > $1[keyPath: keyPath] ?? 0 })
            .last?[keyPath: keyPath]
        return total ?? 0
    }
    
    /// This func delivers the total amount of visibles for a product. If it finds a non-default currency amount, the func will return nil.
    public func totalOfVisiblesIfOnlyEuro(with value: KeyPath<Product, AmountDTO?>) -> Decimal? {
        guard !visibles().contains(where: { $0[keyPath: value]?.currency?.currencyType != CoreCurrencyDefault.default }) else { return nil }
        return visibles().reduce(0, { $0 + ($1[keyPath: value]?.value ?? 0) })
    }
}

public protocol GlobalPositionWithUserPrefsRepresentable: AnyObject {
    var userPref: UserPrefEntity? { get }
    var userId: String? { get }
    var userCodeType: String? { get }
    var dto: GlobalPositionDTO? { get }
    var accounts: GlobalPositionProductList<AccountEntity> { get }
    var cards: GlobalPositionProductList<CardEntity> { get }
    var stockAccounts: GlobalPositionProductList<StockAccountEntity> { get }
    var loans: GlobalPositionProductList<LoanEntity> { get }
    var deposits: GlobalPositionProductList<DepositEntity> { get }
    var pensions: GlobalPositionProductList<PensionEntity> { get }
    var funds: GlobalPositionProductList<FundEntity> { get }
    var notManagedPortfolios: GlobalPositionProductList<PortfolioEntity> { get }
    var managedPortfolios: GlobalPositionProductList<PortfolioEntity> { get }
    var notManagedPortfolioVariableIncome: GlobalPositionProductList<StockAccountEntity> { get }
    var managedPortfolioVariableIncome: GlobalPositionProductList<StockAccountEntity> { get }
    var insuranceSavings: GlobalPositionProductList<InsuranceSavingEntity> { get }
    var protectionInsurances: GlobalPositionProductList<InsuranceProtectionEntity> { get }
    var savingProducts: GlobalPositionProductList<SavingProductEntity> { get }
    var isPb: Bool? { get }
    var clientNameWithoutSurname: String? { get }
    var clientBirthDate: Date? { get }
    var allAccountsWithoutPiggy: [AccountEntity] { get }
    var accountsVisiblesWithoutPiggy: [AccountEntity] { get }
    var accountsNotVisiblesWithoutPiggy: [AccountEntity] { get }
    var fullName: String? { get }
}

public extension GlobalPositionWithUserPrefsRepresentable {
    var availableName: String? {
        guard let name = dto?.clientNameWithoutSurname,
              let lastName = dto?.clientFirstSurname?.surname,
              !name.isEmpty, !lastName.isEmpty else { return dto?.clientName ?? "" }
        return "\(name) \(lastName)"
    }

    var clientBothSurnames: String? {
        guard let first = dto?.clientFirstSurname?.surname, let second = dto?.clientSecondSurname?.surname else { return nil }
        return "\(first) \(second)"
    }

    var clientSurname: String? {
        return dto?.clientFirstSurname?.surname
    }
    
    var completeName: String? {
        return dto?.clientName
    }
}
