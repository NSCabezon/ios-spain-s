import Foundation

class OnePayTransferDestinationSegmentModel: TableModelViewItem<OnePayTransferDestinationSegmentCell> {
    
    var didSelectOption: ((Int) -> Void)?
    var options: [String]
    var currentOption: Int?
    
    init(options: [String], dependencies: PresentationComponent) {
        self.options = options
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: OnePayTransferDestinationSegmentCell) {
        viewCell.options(options)
        viewCell.didSelectOptionCompletion = { [weak self] index in
            self?.didSelectOption?(index)
        }
        if let currentOption = currentOption {
            viewCell.selectOption(currentOption)
        }
    }
    
}
