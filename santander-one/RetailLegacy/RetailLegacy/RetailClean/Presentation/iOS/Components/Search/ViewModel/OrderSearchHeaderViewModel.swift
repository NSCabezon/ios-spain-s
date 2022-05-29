import Foundation

class OrderSearchHeaderViewModel: HeaderViewModel<GenericOperativeHeaderOneLineView> {
    
    var stockAccount: StockAccount
    private let dependencies: PresentationComponent
    
    init(stockAccount: StockAccount, dependencies: PresentationComponent) {
        self.stockAccount = stockAccount
        self.dependencies = dependencies
    }
    
    override func configureView(_ view: GenericOperativeHeaderOneLineView) {
        view.titleLabel.set(localizedStylableText: .plain(text: stockAccount.getAlias()))
        view.amountlabel.set(localizedStylableText: .plain(text: stockAccount.getAmountUI()))
    }
    
}
