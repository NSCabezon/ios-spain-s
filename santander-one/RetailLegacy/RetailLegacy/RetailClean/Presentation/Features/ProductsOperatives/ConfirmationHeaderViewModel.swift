import Foundation

class ConfirmationHeaderViewModel: TableModelViewItem<ConfirmationHeaderTableViewCell> {
    
    // MARK: - Private attributes
    private let amount: String
    private let concept: String?
    
    // MARK: - Public methods
    init(dependencies: PresentationComponent, amount: String, concept: String? = nil) {
        self.amount = amount
        self.concept = concept
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: ConfirmationHeaderTableViewCell) {
        viewCell.amount = amount
        viewCell.concept = concept
    }
}
