import Foundation

class ProductProfileSearchHeaderViewModel: HeaderViewModel<GenericOperativeHeaderOneLineView> {
    
    private let product: PortfolioProduct
    private let dependencies: PresentationComponent
    
    init(product: PortfolioProduct, dependencies: PresentationComponent) {
        self.product = product
        self.dependencies = dependencies
    }
    
    override func configureView(_ view: GenericOperativeHeaderOneLineView) {
        view.titleLabel.set(localizedStylableText: .plain(text: product.getAlias()))
        view.amountlabel.set(localizedStylableText: .plain(text: product.getAmountUI()))
    }
    
}
