import SANLegacyLibrary
import CoreDomain

public class GlobalPositionPrefsMergerEntity {
    public var userPref: UserPrefEntity?
    private let resolver: DependenciesResolver
    public var globalPosition: GlobalPositionRepresentable
    private let appRepositoryProtocol: AppRepositoryProtocol
    private var shouldSetUserPref: Bool = false
    
    struct ProductInBox<P: GlobalPositionProduct> {
        
        let order: Int
        let product: P
        
        init(order: Int, product: P) {
            self.order = order
            self.product = product
        }
    }
    
    public init(resolver: DependenciesResolver, globalPosition: GlobalPositionRepresentable, userPref: UserPrefEntity? = nil, saveUserPreferences: Bool) {
        self.resolver = resolver
        self.globalPosition = globalPosition
        self.appRepositoryProtocol = resolver.resolve(for: AppRepositoryProtocol.self)
        self.userPref = userPref ?? UserPrefEntity.from(dto: appRepositoryProtocol.getUserPreferences(userId: globalPosition.userId ?? ""))
        self.updateUserPrefs()
        if saveUserPreferences {
            self.setUserPreferences()
        }
    }
    
    private func updateUserPrefs() {
        globalPosition.accounts = update(products: globalPosition.accounts,
                                         andUserPrefsType: .account)
        globalPosition.cards = update(products: globalPosition.cards,
                                      andUserPrefsType: .card)
        globalPosition.stockAccounts = update(products: globalPosition.stockAccounts,
                                              andUserPrefsType: .stock)
        globalPosition.loans = update(products: globalPosition.loans,
                                      andUserPrefsType: .loan)
        globalPosition.deposits = update(products: globalPosition.deposits,
                                         andUserPrefsType: .deposit)
        globalPosition.pensions = update(products: globalPosition.pensions,
                                         andUserPrefsType: .pension)
        globalPosition.funds = update(products: globalPosition.funds,
                                      andUserPrefsType: .fund)
        globalPosition.notManagedPortfolios = update(products: globalPosition.notManagedPortfolios,
                                                     andUserPrefsType: .notManagedPortfolio)
        globalPosition.managedPortfolios = update(products: globalPosition.managedPortfolios,
                                                  andUserPrefsType: .managedPortfolio)
        globalPosition.notManagedPortfolioVariableIncome = update(products: globalPosition.notManagedPortfolioVariableIncome,
                                                                  andUserPrefsType: .notManagedPortfolioVariableIncome)
        globalPosition.managedPortfolioVariableIncome = update(products: globalPosition.managedPortfolioVariableIncome,
                                                               andUserPrefsType: .managedPortfolioVariableIncome)
        globalPosition.insuranceSavings = update(products: globalPosition.insuranceSavings,
                                                 andUserPrefsType: .insuranceSaving)
        globalPosition.protectionInsurances = update(products: globalPosition.protectionInsurances,
                                                     andUserPrefsType: .insuranceProtection)
        globalPosition.savingProducts = update(products: globalPosition.savingProducts, andUserPrefsType: .savingProduct)
    }
    
    private func update<P: GlobalPositionProduct>(products: [P], andUserPrefsType boxType: UserPrefBoxType) -> [P] {
        guard var lookupBox = userPref?.userPrefDTOEntity.pgUserPrefDTO.boxes[boxType] else {
            return setNewBox(products: products, andUserPrefsType: boxType)
        }
        var maxIndex = lookupBox.products.values.map({ $0.order }).max() ?? 0
        if products.isEmpty &&
            !lookupBox.products.isEmpty {
            lookupBox.removeAllItems()
            userPref?.userPrefDTOEntity.pgUserPrefDTO.boxes[boxType] = lookupBox
            self.shouldSetUserPref = true
            return []
        } else {
            var newBox = PGBoxDTOEntity(order: lookupBox.order, isOpen: lookupBox.isOpen)
            var newProducts: [ProductInBox<P>] = []
            var products = products
            for index in products.indices {
                if let userPrefProduct = lookupBox.getItem(withIdentifier: products[index].productIdentifier) {
                    products[index].isVisible = userPrefProduct.isVisible
                    newBox.set(item: userPrefProduct, withIdentifier: products[index].productIdentifier)
                    newProducts.append(ProductInBox(order: userPrefProduct.order, product: products[index]))
                } else {
                    maxIndex += 1
                    let newItem = PGBoxItemDTOEntity(order: maxIndex, isVisible: products[index].isVisible)
                    newBox.set(item: newItem, withIdentifier: products[index].productIdentifier)
                    newProducts.append(ProductInBox(order: maxIndex, product: products[index]))
                    self.shouldSetUserPref = true
                }
            }
            userPref?.userPrefDTOEntity.pgUserPrefDTO.boxes[boxType] = newBox
            return newProducts.sorted(by: { $0.order < $1.order }).map({ $0.product })
        }
    }
    
    private func setNewBox<P: GlobalPositionProduct>(products: [P], andUserPrefsType boxType: UserPrefBoxType) -> [P] {
        var newBox = PGBoxDTOEntity(order: boxType.asProductType.getPosition(isPB: globalPosition.isPb ?? false))
        for (index, product) in products.enumerated() {
            newBox.set(item: PGBoxItemDTOEntity(order: index, isVisible: true), withIdentifier: product.productIdentifier)
        }
        userPref?.userPrefDTOEntity.pgUserPrefDTO.boxes[boxType] = newBox
        self.shouldSetUserPref = true
        return products
    }
    
    private func setUserPreferences() {
        guard self.shouldSetUserPref, let userPrefFinal = self.userPref?.userPrefDTOEntity else { return }
        self.appRepositoryProtocol.setUserPreferences(userPref: userPrefFinal)
    }
}

extension GlobalPositionPrefsMergerEntity: GlobalPositionWithUserPrefsRepresentable {
    public var userId: String? {
        globalPosition.userId
    }
    
    public var userCodeType: String? {
        globalPosition.userCodeType
    }
    
    public var dto: GlobalPositionDTO? {
        globalPosition.dto
    }
    
    public var accounts: GlobalPositionProductList<AccountEntity> {
        GlobalPositionProductList(products: globalPosition.accounts)
    }
    
    public var cards: GlobalPositionProductList<CardEntity> {
        GlobalPositionProductList(products: globalPosition.cards)
    }
    
    public var stockAccounts: GlobalPositionProductList<StockAccountEntity> {
        GlobalPositionProductList(products: globalPosition.stockAccounts)
    }
    
    public var loans: GlobalPositionProductList<LoanEntity> {
        GlobalPositionProductList(products: globalPosition.loans)
    }
    
    public var deposits: GlobalPositionProductList<DepositEntity> {
        GlobalPositionProductList(products: globalPosition.deposits)
    }
    
    public var pensions: GlobalPositionProductList<PensionEntity> {
        GlobalPositionProductList(products: globalPosition.pensions)
    }
    
    public var funds: GlobalPositionProductList<FundEntity> {
        GlobalPositionProductList(products: globalPosition.funds)
    }
    
    public var notManagedPortfolios: GlobalPositionProductList<PortfolioEntity> {
        GlobalPositionProductList(products: globalPosition.notManagedPortfolios)
    }
    
    public var managedPortfolios: GlobalPositionProductList<PortfolioEntity> {
        GlobalPositionProductList(products: globalPosition.managedPortfolios)
    }
    
    public var notManagedPortfolioVariableIncome: GlobalPositionProductList<StockAccountEntity> {
        GlobalPositionProductList(products: globalPosition.notManagedPortfolioVariableIncome)
    }
    
    public var managedPortfolioVariableIncome: GlobalPositionProductList<StockAccountEntity> {
        GlobalPositionProductList(products: globalPosition.managedPortfolioVariableIncome)
    }
    
    public var insuranceSavings: GlobalPositionProductList<InsuranceSavingEntity> {
        GlobalPositionProductList(products: globalPosition.insuranceSavings)
    }
    
    public var protectionInsurances: GlobalPositionProductList<InsuranceProtectionEntity> {
        GlobalPositionProductList(products: globalPosition.protectionInsurances)
    }
    
    public var savingProducts: GlobalPositionProductList<SavingProductEntity> {
        GlobalPositionProductList(products: globalPosition.savingProducts)
    }
    
    public var isPb: Bool? {
        globalPosition.isPb
    }
    
    public var clientNameWithoutSurname: String? {
        dto?.clientNameWithoutSurname
    }
    
    public var clientBirthDate: Date? {
        dto?.clientBirthDate
    }
    
    public var accountsVisiblesWithoutPiggy: [AccountEntity] {
        let accountGlobalPosition = GlobalPositionProductList(products: globalPosition.accounts)
        return accountGlobalPosition.visibles().filter({ !$0.isPiggyBankAccount })
    }

    public var accountsNotVisiblesWithoutPiggy: [AccountEntity] {
        let accountGlobalPosition = GlobalPositionProductList(products: globalPosition.accounts)
        return accountGlobalPosition.notVisibles.filter({ !$0.isPiggyBankAccount })
    }
    
    public var allAccountsWithoutPiggy: [AccountEntity] {
        let accountGlobalPosition = GlobalPositionProductList(products: globalPosition.accounts)
        return accountGlobalPosition.all().filter({ !$0.isPiggyBankAccount })
    }
    
    public var fullName: String? {
        globalPosition.fullName
    }
}
