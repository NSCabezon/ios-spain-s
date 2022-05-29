import Foundation

class PensionSearchHeaderViewModel: HeaderViewModel<GenericOperativeHeaderOneLineView> {
    
    var pension: Pension
    private let dependencies: PresentationComponent
    
    init(pension: Pension, dependencies: PresentationComponent) {
        self.pension = pension
        self.dependencies = dependencies
    }
    
    override func configureView(_ view: GenericOperativeHeaderOneLineView) {
        view.titleLabel.set(localizedStylableText: .plain(text: pension.getAlias()))
        view.amountlabel.set(localizedStylableText: .plain(text: pension.getAmountUI()))
    }
    
}
