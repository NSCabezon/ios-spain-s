import Foundation

class SearchParameterSegmentedOptionViewModel: TableModelViewItem<SearchParameterSegementedOptionTableViewCell>, Clearable {
    
    var didSelectOption: ((Int) -> Void)?
    var options: [String]
    var currentOption: Int?
    private var clearData: (() -> Void)?

    init(options: [String], dependencies: PresentationComponent) {
        self.options = options
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: SearchParameterSegementedOptionTableViewCell) {
        viewCell.options(options)
        viewCell.didSelectOptionCompletion = { [weak self] index in
            self?.didSelectOption?(index)
        }
        if let currentOption = currentOption {
            viewCell.selectOption(currentOption)
        }
        clearData = { [weak self, weak viewCell] in
            guard let strongSelf = self else { return }
            strongSelf.currentOption = 0
            viewCell?.selectOption(0)
        }

    }
    
    func clear() {
        clearData?()
    }
    
}
