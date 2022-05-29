import Foundation

protocol InputRequester {
    func requestDate()
}

class SearchParameterDateViewModel: TableModelViewItem<SearchParameterDateTableViewCell> {
    
    var enteredDateFrom: ((Date?) -> Void)?
    var enteredDateTo: ((Date?) -> Void)?
    weak var searchInputProvider: SearchInputProvider?
    var currentDateFrom: Date?
    var currentDateTo: Date?
    var defaultDateFrom: Date?
    var minumumDateAllowed: Date?

    override func bind(viewCell: SearchParameterDateTableViewCell) {
        let stringLoader = dependencies.stringLoader
        viewCell.title(stringLoader.getString("search_text_searchDate"))
        let fromTitle = minumumDateAllowed != nil
            ? stringLoader.getString("search_label_sinceAccount", [StringPlaceholder(.value, "24")])
            : stringLoader.getString("search_label_since")
        viewCell.titleFromDate(fromTitle)
        viewCell.titleToDate(stringLoader.getString("search_label_until"))
        viewCell.dateFrom(dependencies.timeManager.toString(date: currentDateFrom, outputFormat: .d_MMM_yyyy))
        viewCell.textFieldFromTapped = { [weak self, weak viewCell] in
            self?.searchInputProvider?.requestDate(currentDate: self?.currentDateFrom ?? self?.defaultDateFrom, minimumDate: self?.minumumDateAllowed, maximumDate: self?.currentDateTo ?? Date(), completion: { (date) in
                guard let date = date else { return }
                self?.enteredDateFrom?(date)
                self?.currentDateFrom = date
                viewCell?.dateFrom(self?.dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy))
            })
        }
        viewCell.dateTo(dependencies.timeManager.toString(date: currentDateTo, outputFormat: .d_MMM_yyyy))
        viewCell.textFieldToTapped = { [weak self, weak viewCell] in
            self?.searchInputProvider?.requestDate(currentDate: self?.currentDateTo, minimumDate: self?.currentDateFrom, maximumDate: Date(), completion: { (date) in
                guard let date = date else { return }
                self?.enteredDateTo?(date)
                self?.currentDateTo = date
                viewCell?.dateTo(self?.dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy))
            })
        }
    }
    
}
