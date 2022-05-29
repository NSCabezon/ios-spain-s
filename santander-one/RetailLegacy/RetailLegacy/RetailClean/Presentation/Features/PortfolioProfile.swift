import CoreFoundationLib
import UIKit
import CoreDomain

final class PortfolioProfile: BaseProductHomeProfile<Portfolio, Void, GetPortfolioProductListUseCaseInput, GetPortfolioProductListUseCaseOkOutput, GetPortfolioProductListUseCaseErrorOutput, PortfolioProduct>, ProductProfile {
    var menuOptionSelected: PrivateMenuOptions? {
        return .sofiaInvestments
    }
    
    let isManagedPortfolio: Bool
    
    var loadingPlaceholder: Placeholder {
        return Placeholder("portfolioPlaceholderFake", 14)
    }
    
    override var loadingTopInset: Double {
        return 0
    }
    
    var productTitle: LocalizedStylableText {
        return isManagedPortfolio ? dependencies.stringLoader.getString("toolbar_title_portfolioManaged") : dependencies.stringLoader.getString("toolbar_title_portfolioNoManaged")
    }
    
    override var transactionHeaderTitle: LocalizedStylableText? {
        return LocalizedStylableText(text: "", styles: nil).uppercased()
    }
    
    var isFilterIconVisible: Bool {
        return false
    }
    var showNavigationInfo: Bool {
        return false
    }
    override var isMorePages: Bool {
        return false
    }
    override var hasDefaultRows: Bool {
        return false
    }
    
    override var needsExtraBottomSpace: Bool {
        return true
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return nil
    }

    // MARK: -

    init(isManaged: Bool, selectedProduct: GenericProduct?, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, delegate: ProductHomeProfileDelegate, shareDelegate: ShowShareType?) {
        self.isManagedPortfolio = isManaged
        super.init(selectedProduct: selectedProduct,
                   dependencies: dependencies,
                   errorHandler: errorHandler,
                   delegate: delegate,
                   shareDelegate: shareDelegate)
        
        UseCaseWrapper(with: dependencies.useCaseProvider.deletePortfoliosProductsUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler)
    }
        
    override func menuOptions(withProductConfig productConfig: ProductConfig) {
        // This should do nothing
    }
    
    func transactionDidSelected(at index: Int) {
        transactionList[index].action?()
    }
    
    override func useCaseForTransactions<Input, Response, Error>(pagination: PaginationDO?) -> UseCase<Input, Response, Error>? where Error: StringErrorOutput {
        guard let currentPosition = currentPosition else {
            return nil
        }
        let portfolio = productList[currentPosition]
        let input = GetPortfolioProductListUseCaseInput(portfolio: portfolio)
        return dependencies.useCaseProvider.getPortfolioProductListUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    override func convertToProductHeader(element: Portfolio, position: Int) -> CarouselItem {
        let data = ProductHeader(title: element.getAliasUpperCase(),
                                 subtitle: element.getDetailUI(),
                                 amount: element.getAmount(),
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: true,
                                 copyTag: nil,
                                 isBigSeparator: needsExtraBottomSpace,
                                 shareDelegate: self)
        return CarouselGenericCell(data: data)
    }
    
    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [Portfolio] {
        if isManagedPortfolio {
            return globalPosition.managedPortfolios.get(ordered: true, visibles: true)
        }
        return globalPosition.notManagedPortfolios.get(ordered: true, visibles: true)
    }
    
    override func paginationFrom(response: GetPortfolioProductListUseCaseOkOutput) -> PaginationDO? {
        return nil
    }
    
    override func transactionsFrom(response: GetPortfolioProductListUseCaseOkOutput) -> [PortfolioProduct]? {
        var result = [PortfolioProduct]()

        let portfolio: Portfolio?
        
        if let position = currentPosition, productList.count > position {
            portfolio = productList[position]
        } else {
            portfolio = nil
        }
        
        for section in Sections.orderedSections {
            let group = response.transactions.filter({
                if let id = $0.portfolioBlockDesc {
                    return id.lowercased() == section.groupIdentifier.lowercased()
                }
                return false })
            guard !group.isEmpty else {
                continue
            }
            let isEuroOnly = group.filter({ $0.impUltSaldoConsolidado?.currency?.currencyType != .eur }).isEmpty
            let total: String?
            let isAmountTotal: Bool
            if isEuroOnly, let symbol = group.first?.impUltSaldoConsolidado?.currency?.getSymbol() {
                total = group.reduce(0, { $0 + ($1.impUltSaldoConsolidado?.value ?? 0) }).getFormattedAmountUIWith1M(currencySymbol: symbol)
                isAmountTotal = true
            } else {
                total = nil
                isAmountTotal = false
            }
            let isFirstElement = result.isEmpty
            let header = PortfolioProduct(section: section, amount: total, isFirstElement: isFirstElement, isAmountTotal: isAmountTotal, portfolioBlockDesc: section.groupIdentifier)
            result.append(header)
            let items: [PortfolioProduct] = group.map({PortfolioProduct(section: section, portfolio: portfolio, product: $0, isActionAsociated: section.isActionable)})

            var i: Int = 0
            items.forEach({ (product) in
                guard section.isActionable else {
                    return
                }
                product.action = {
                    let selectedPosition = items.firstIndex(of: product) ?? 0
                    switch section {
                    case .investmentFund:
                        self.delegate?.goToTransactionDetail(product: product, transactions: items, selectedPosition: selectedPosition, productHome: .productProfileFund)
                    case .plans:
                        self.delegate?.goToTransactionDetail(product: product, transactions: items, selectedPosition: selectedPosition, productHome: .productProfilePlans)
                    case .variableIncome:
                        self.delegate?.goToTransactionDetail(product: product, transactions: items, selectedPosition: selectedPosition, productHome: self.isManagedPortfolio ? .productProfileVariableIncomeManaged: .productProfileVariableIncomeNotManaged)
                    default:
                        break
                    }
                }
                i += 1
            })
            result.append(contentsOf: items)
        }
        
        return result
    }

    override func convertToDateProvider(from transaction: PortfolioProduct) -> DateProvider {
        if transaction.isTitle {
            return PortfolioProductTitleModelView(title: Sections.getSectionTitleById(stringLoader: dependencies.stringLoader, id: transaction.portfolioBlockDesc), diferentCurrency: dependencies.stringLoader.getString("pgBasket_label_differentCurrency"), amount: transaction.amount, isFirstElement: transaction.isFirstElement, privateComponent: dependencies)
        } else {
            return PortfolioProductModelView(product: transaction, privateComponent: dependencies)
        }
    }
    
    override func infoToShareWithCode(_ code: Int?) -> String {
        let position = currentPosition ?? 0
        let product = productList[position]
        let info = product.getDetailUI()

        return info
    }
}

enum Sections: Int {
    case investmentFund
    case fixedIncome
    case variableIncome
    case derivative
    case insurance
    case plans
    
    static let orderedSections: [Sections] = [.investmentFund, .fixedIncome, .variableIncome, .derivative, .insurance, .plans]
    
    func title(stringLoader: StringLoader) -> LocalizedStylableText {
        var text: LocalizedStylableText
        switch self {
        case .investmentFund:
            text = stringLoader.getString("portfolioProduct_block_funds")
        case .fixedIncome:
            text = stringLoader.getString("portfolioProduct_block_fixedRetn")
        case .variableIncome:
            text = stringLoader.getString("portfolioProduct_block_variableRent")
        case .derivative:
            text = stringLoader.getString("portfolioProduct_block_derivatives")
        case .insurance:
            text = stringLoader.getString("portfolioProduct_block_insurance")
        case .plans:
            text = stringLoader.getString("portfolioProduct_block_palns")
        }
        text.text = text.text.uppercased()
        return text
    }
    
    static func getSectionTitleById(stringLoader: StringLoader, id: String) -> LocalizedStylableText {
        var text: LocalizedStylableText
        switch id {
        case Sections.investmentFund.groupIdentifier:
            text = stringLoader.getString("portfolioProduct_block_funds")
        case Sections.fixedIncome.groupIdentifier:
            text = stringLoader.getString("portfolioProduct_block_fixedRetn")
        case Sections.variableIncome.groupIdentifier:
            text = stringLoader.getString("portfolioProduct_block_variableRent")
        case Sections.derivative.groupIdentifier:
            text = stringLoader.getString("portfolioProduct_block_derivatives")
        case Sections.insurance.groupIdentifier:
            text = stringLoader.getString("portfolioProduct_block_insurance")
        case Sections.plans.groupIdentifier:
            text = stringLoader.getString("portfolioProduct_block_palns")
        default:
            text = LocalizedStylableText(text: "", styles: nil)
        }
        text.text = text.text.uppercased()
        return text
    }
    
    var groupIdentifier: String {
        switch self {
        case .investmentFund:
            return "Fondos de inversión"
        case .fixedIncome:
            return "Renta fija"
        case .variableIncome:
            return "Renta Variable"
        case .derivative:
            return "Derivados"
        case .insurance:
            return "Seguros"
        case .plans:
            return "Planes"
        }
    }
    
    var isActionable: Bool {
        switch self {
        case .derivative, .insurance, .fixedIncome:
            return false
        case .investmentFund, .plans, .variableIncome:
            return true
        }
    }
}
