//

import UIKit

class RadioButtonAndDateViewModel: RadioButtonViewModel<RadioButtonAndDateCell>, DatePickerControllerConfiguration {
    
    var date: Date?
    var lowerLimitDate: Date?
    var upperLimitDate: Date?
    
    override func bind(viewCell: RadioButtonAndDateCell) {
        super.bind(viewCell: viewCell)
        if let date = date {
            viewCell.date = formatDate(date: date)
        }
        viewCell.newDateValue = { [weak self] newDate in
            self?.date = self?.dependencies.timeManager.fromString(input: newDate, inputFormat: .d_MMM_yyyy)
        }
    }
}

extension RadioButtonAndDateViewModel: DateSelectionViewModel {
    
    func formatDate(date: Date) -> String {
        return dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy) ?? ""
    }
}
