import Foundation

class FundSearchHeaderViewModel: HeaderViewModel<GenericOperativeHeaderOneLineView> {
    
    var fund: Fund
    private let dependencies: PresentationComponent
    
    init(fund: Fund, dependencies: PresentationComponent) {
        self.fund = fund
        self.dependencies = dependencies
    }
    
    override func configureView(_ view: GenericOperativeHeaderOneLineView) {
        view.titleLabel.set(localizedStylableText: .plain(text: fund.getAlias()?.camelCasedString))
        view.amountlabel.set(localizedStylableText: .plain(text: fund.getAmountUI()))
    }
    
}
