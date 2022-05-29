import Foundation

class SearchParameterAmountRangeViewModel: TableModelViewItem<SearchParameterAmountRangeTableViewCell>, Clearable {
    
    var enteredAmountFrom: ((String?) -> Void)?
    var enteredAmountTo: ((String?) -> Void)?
    weak var searchInputProvider: SearchInputProvider?
    var currentAmountFrom: String?
    var currentAmountTo: String?
    private var clearData: (() -> Void)?
    
    override func bind(viewCell: SearchParameterAmountRangeTableViewCell) {
        let stringLoader = dependencies.stringLoader
        viewCell.title(stringLoader.getString("search_label_value"))
        viewCell.fromTitle(stringLoader.getString("search_label_since"))
        viewCell.toTitle(stringLoader.getString("search_label_until"))
        viewCell.fromText = currentAmountFrom
        viewCell.didChangeTextFieldFrom = { [weak self] newValue in
            guard let newValue = newValue else { return }
            self?.enteredAmountFrom?(newValue)
            self?.currentAmountFrom = newValue
        }
        viewCell.toText = currentAmountTo
        viewCell.didChangeTextFieldTo = { [weak self] newValue in
            guard let newValue = newValue else { return }
            self?.enteredAmountTo?(newValue)
            self?.currentAmountTo = newValue
        }
        clearData = { [weak viewCell] in
            viewCell?.fromText = nil
            viewCell?.toText = nil
        }
    }
    
    func clear() {
        clearData?()
    }
    
}
