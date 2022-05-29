import Foundation

class SearchParameterDateRangeOneRowViewModel: TableModelViewItem<SearchParameterDateRangeUITableViewCell>, Clearable {

    var enteredDateFrom: ((Date?) -> Void)?
    var enteredDateTo: ((Date?) -> Void)?
    weak var searchInputProvider: SearchInputProvider?
    var currentDateFrom: Date?
    var currentDateTo: Date?
    var defaultDateFrom: Date?
    private var clearData: (() -> Void)?
    var minumumDateAllowed: Date?
    var bottomSpace: Double = 16
    
    override func bind(viewCell: SearchParameterDateRangeUITableViewCell) {
        viewCell.bottomSpace = bottomSpace
        let stringLoader = dependencies.stringLoader
        viewCell.title(stringLoader.getString("search_text_searchMoves"))
        viewCell.subtitle(stringLoader.getString("search_label_datesInterval"))
        let fromTitle = minumumDateAllowed != nil
            ? stringLoader.getString("search_label_sinceAccount", [StringPlaceholder(.value, "24")])
            : stringLoader.getString("search_label_since")
        viewCell.fromTitle(fromTitle)
        viewCell.toTitle(stringLoader.getString("search_label_until"))        
        viewCell.fromText = dependencies.timeManager.toString(date: currentDateFrom, outputFormat: .d_MMM_yyyy)
        viewCell.textFieldFromTapped = { [weak self, weak viewCell] in
            self?.searchInputProvider?.requestDate(currentDate: self?.currentDateFrom ?? self?.defaultDateFrom, minimumDate: self?.minumumDateAllowed, maximumDate: self?.currentDateTo ?? Date(), completion: { (date) in
                guard let date = date else { return }
                self?.enteredDateFrom?(date)
                self?.currentDateFrom = date
                viewCell?.fromText = self?.dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy)
            })
        }
        viewCell.toText = dependencies.timeManager.toString(date: currentDateTo, outputFormat: .d_MMM_yyyy)
        viewCell.textFieldToTapped = { [weak self, weak viewCell] in
            self?.searchInputProvider?.requestDate(currentDate: self?.currentDateTo, minimumDate: self?.currentDateFrom, maximumDate: Date(), completion: { (date) in
                guard let date = date else { return }
                self?.enteredDateTo?(date)
                self?.currentDateTo = date
                viewCell?.toText = self?.dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy)
            })
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
