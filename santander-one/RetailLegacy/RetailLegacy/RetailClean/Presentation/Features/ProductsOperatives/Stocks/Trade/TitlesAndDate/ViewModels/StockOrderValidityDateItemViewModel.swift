import UIKit

protocol StockOrderValidityDateItemViewModelDelegate: class {
    func dateCleared()
}

class StockOrderValidityDateItemViewModel: TableModelViewItem<StockOrderValidityDateTableViewCell>, DatePickerControllerConfiguration {
    
    var placeholder: LocalizedStylableText
    var date: Date?
    var lowerLimitDate: Date?
    var upperLimitDate: Date?
    var textFieldStyle: TextFieldStylist
    weak var delegate: StockOrderValidityDateItemViewModelDelegate?
    
    init(placeholder: LocalizedStylableText, date: Date?, textFieldStyle: TextFieldStylist, privateComponent: PresentationComponent) {
        self.placeholder = placeholder
        self.date = date
        self.textFieldStyle = textFieldStyle
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: StockOrderValidityDateTableViewCell) {
        (viewCell.textField as UITextField).applyStyle(textFieldStyle)
        viewCell.textCleared = { [weak self] in
            self?.date = nil
            self?.delegate?.dateCleared()
        }
        viewCell.newDateValue = { [weak self] date in
            self?.date = self?.dependencies.timeManager.fromString(input: date, inputFormat: .d_MMM_yyyy)
        }
        if let date = date {
            viewCell.date = formatDate(date: date)
        } else {
            viewCell.styledPlaceholder = placeholder
        }
    }
}

extension StockOrderValidityDateItemViewModel: DateSelectionViewModel {
    func formatDate(date: Date) -> String {
        return dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy) ?? ""
    }
}
