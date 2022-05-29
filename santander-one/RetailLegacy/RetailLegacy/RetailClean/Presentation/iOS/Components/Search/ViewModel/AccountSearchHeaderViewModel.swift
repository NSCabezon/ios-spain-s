import Foundation

class AccountSearchHeaderViewModel: HeaderViewModel<GenericOperativeHeaderOneLineView> {
    
    var account: Account
    private let dependencies: PresentationComponent
    
    init(account: Account, dependencies: PresentationComponent) {
        self.account = account
        self.dependencies = dependencies
    }
    
    override func configureView(_ view: GenericOperativeHeaderOneLineView) {
        view.titleLabel.set(localizedStylableText: .plain(text: account.getAlias()))
        view.amountlabel.set(localizedStylableText: .plain(text: account.getAmountUI()))
    }
    
}
