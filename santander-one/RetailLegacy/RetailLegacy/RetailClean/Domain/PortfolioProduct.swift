import Foundation
import SANLegacyLibrary
import CoreDomain

final class PortfolioProduct: GenericProduct {
    let portfolio: Portfolio?
    let product: PortfolioProductDTO?
    let title: String?
    let subtitle: String?
    let amount: String?
    let isFirstElement: Bool
    let isAmountTotal: Bool
    let isActionAsociated: Bool
    var action: (() -> Void)?
    var blockDescription: String?
    var section: Sections
    
    var isTitle: Bool {
        return product == nil
    }
    
    var portfolioBlockDesc: String {
        if let blockDescription = blockDescription {
            return blockDescription
        } else if let blockDescription = product?.portfolioBlockDesc {
            return blockDescription
        } else {
            return ""
        }
    }
    
    init(section: Sections, portfolio: Portfolio?, product: PortfolioProductDTO, isActionAsociated: Bool) {
        self.section = section
        self.portfolio = portfolio
        self.product = product
        self.title = product.alias
        self.amount = Amount.createFromDTO(product.impUltSaldoConsolidado).getFormattedAmountUIWith1M()
        if let number = product.accountDesc {
            self.subtitle = "***" + number.dropFirst(number.count - 4)
        } else {
            self.subtitle = " "
        }
        self.isFirstElement = false
        self.isAmountTotal = true
        self.isActionAsociated = isActionAsociated
        self.blockDescription = nil
        super.init()
    }
    
    init(section: Sections, amount: String?, isFirstElement: Bool, isAmountTotal: Bool, portfolioBlockDesc: String?) {
        self.section = section
        self.product = nil
        self.title = nil
        self.amount = amount
        self.subtitle = nil
        self.isFirstElement = isFirstElement
        self.isAmountTotal = isAmountTotal
        self.isActionAsociated = false
        self.portfolio = nil
        self.blockDescription = portfolioBlockDesc
        super.init()
    }
    
    // MARK: - GenericProduct
    
    override func getAlias() -> String? {
        return product?.alias
    }
    
    override func getDetailUI() -> String? {
        return product?.accountDesc
    }
    
    override func getAmountValue() -> Decimal? {
        return product?.impUltSaldoConsolidado?.value
    }
    
    override func getAmountCurrency() -> CurrencyDTO? {
        return product?.impUltSaldoConsolidado?.currency
    }
    
    override func getTipoInterv() -> OwnershipTypeDesc? {
        return nil
    }
    
    override func getCounterValueAmountValue() -> Decimal? {
        if let amount = Amount.createFromDTO(product?.countervalueAmount).value {
            return amount
        }
        return nil
    }
    
    func getPortfolioAliasUI() -> String? {
        return portfolio?.getDetailUI()
    }
    
    override func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        return ""
    }
}

// MARK: - GenericProductProtocol

extension PortfolioProduct: GenericProductProtocol {}

// MARK: - GenericTransactionProtocol

extension PortfolioProduct: GenericTransactionProtocol {}

// MARK: - Equatable

extension PortfolioProduct: Equatable {
    static func == (lhs: PortfolioProduct, rhs: PortfolioProduct) -> Bool {
        return lhs.getAlias() == rhs.getAlias() &&
            lhs.getDetailUI() == rhs.getDetailUI() &&
            lhs.getAmountValue() == rhs.getAmountValue() &&
            lhs.getAmountCurrency() == rhs.getAmountCurrency() &&
            lhs.getTipoInterv() == rhs.getTipoInterv()
    }
}

extension PortfolioProduct: ProductWebviewParameters {
    var stockCode: String? {
        return nil
    }
    
    var identificationNumber: String? {
        return nil
    }
    
    var family: String? {
        return nil
    }
    var fundName: String? {
        return product?.valueName
    }
    var portfolioId: String? {
        return product?.portfolioId
    }
    var contractId: String? {
        return nil
    }
}
