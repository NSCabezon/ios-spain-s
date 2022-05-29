class ProductSelection<Product: GenericProduct>: OperativeParameter {
    var productSelected: Product?
    var list: [Product]
    let titleKey: String
    let subTitleKey: String
    var tooltipMessage: String?
    let isProductSelectedWhenCreated: Bool
    
    // MARK: - Public methods
    
    init(list: [Product], productSelected: Product?, titleKey: String, subTitleKey: String, tooltipMessage: String? = nil) {
        self.isProductSelectedWhenCreated = productSelected != nil
        self.list = list
        self.productSelected = productSelected
        self.titleKey = titleKey
        self.subTitleKey = subTitleKey
        self.tooltipMessage = tooltipMessage
    }
}
