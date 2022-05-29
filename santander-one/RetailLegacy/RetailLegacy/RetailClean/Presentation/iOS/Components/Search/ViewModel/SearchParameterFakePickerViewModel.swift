import Foundation

class SearchParameterFakePickerViewModel: TableModelViewItem<SearchParameterFakePickerTableViewCell>, Clearable {
    var options: [String]
    var didSelectOption: ((Int?) -> Void)?
    weak var searchInputProvider: SearchInputProvider?
    var currentPosition: Int
    var titleKey = "search_label_orders"
    private var clearData: (() -> Void)?
    
    init(options: [String], currentPosition: Int, dependencies: PresentationComponent) {
        self.options = options
        self.currentPosition = currentPosition
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: SearchParameterFakePickerTableViewCell) {
        let stringLoader = dependencies.stringLoader
        viewCell.title(stringLoader.getString(titleKey))
        viewCell.selectedOption(options[currentPosition])
        viewCell.textFieldTapped = { [weak self, weak viewCell] in
            guard let strongSelf = self else { return }
            strongSelf.searchInputProvider?.requestOptions(strongSelf.options, selectedOption: strongSelf.currentPosition, completion: { (position) in
                guard let position = position else { return }
                strongSelf.didSelectOption?(position)
                strongSelf.currentPosition = position
                viewCell?.selectedOption(strongSelf.options[position])
            })
        }
        clearData = { [weak self, weak viewCell] in
            guard let strongSelf = self else { return }
            strongSelf.currentPosition = 0
            viewCell?.selectedOption(strongSelf.options[strongSelf.currentPosition])
        }
        
    }
    
    func clear() {
        clearData?()
    }
    
}
