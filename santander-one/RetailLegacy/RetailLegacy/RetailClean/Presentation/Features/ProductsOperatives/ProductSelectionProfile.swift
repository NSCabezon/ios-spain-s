import Foundation

/// Use this profile to transform an OperativeProduct (GenericProduct & OperativeParameter) to its ViewModel
class ProductSelectionProfile<Product: GenericProduct> {
    
    // MARK: - Private attributes
    
    private let list: [Product]
    private let dependencies: PresentationComponent
    
    // MARK: - Public methods
    
    init(list: [Product], dependencies: PresentationComponent) {
        self.list = list
        self.dependencies = dependencies
    }
    
    /// Add the whole list of products (converted to ModelView) to the given section
    ///
    /// - Parameter section: a TableModelViewSection
    /// - Throws: if something happends mapping Product to ModelView
    func addToSection(_ section: TableModelViewSection) {
        list.forEach { product in
            switch product {
            case is Account:
                guard let account = product as? Account else { return }
                section.add(item: SelectableAccountViewModel(account, dependencies))
            case is Card:
                guard let card = product as? Card else { return }
                section.add(item: CardWithdrawModelView(card, card.isCreditCard || card.isPrepaidCard, dependencies))
            case is Pension:
                guard let pension = product as? Pension else { return }
                section.add(item: SelectablePensionViewModel(pension, dependencies))
            default:
                section.add(item: SelectableProductViewModel(product, dependencies))
            }
        }
    }
}
