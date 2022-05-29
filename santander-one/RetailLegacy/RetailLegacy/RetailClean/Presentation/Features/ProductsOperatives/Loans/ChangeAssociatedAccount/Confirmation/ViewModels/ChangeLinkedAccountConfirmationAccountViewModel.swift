import Foundation
class ChangeLinkedAccountConfirmationAccountViewModel: TableModelViewItem<GenericConfirmationTableViewCell> {
    
    var account: Account
    
    init(_ account: Account, _ privateComponent: PresentationComponent) {
        self.account = account
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: GenericConfirmationTableViewCell) {
        viewCell.name = account.getAlias()
        viewCell.identifier = account.getIBANShort()
        viewCell.amount = account.getAmountUI()
    }
}
