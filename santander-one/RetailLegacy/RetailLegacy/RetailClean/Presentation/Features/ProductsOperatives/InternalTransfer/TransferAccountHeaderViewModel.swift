//

import Foundation

class TransferAccountHeaderViewModel: TableModelViewItem<TransferAccountHeaderTableViewCell> {
    
    // MARK: - Private attributes
    
    private let amount: String
    private let destinationAccount: String
    private let concept: String?
    
    // MARK: - Public methods
    
    init(dependencies: PresentationComponent, amount: Amount, destinationAccount: Account, concept: String? = nil) {
        self.amount = amount.getAbsFormattedAmountUI()
        self.destinationAccount = destinationAccount.getDetailUI() ?? ""
        self.concept = concept
        super.init(dependencies: dependencies)
    }
    
    init(dependencies: PresentationComponent, amount: String, destinationAccount: String, concept: String? = nil) {
        self.amount = amount
        self.destinationAccount = destinationAccount
        self.concept = concept
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: TransferAccountHeaderTableViewCell) {
        viewCell.amount = amount
        viewCell.destinationAccount = destinationAccount
        viewCell.concept = concept
    }
}
