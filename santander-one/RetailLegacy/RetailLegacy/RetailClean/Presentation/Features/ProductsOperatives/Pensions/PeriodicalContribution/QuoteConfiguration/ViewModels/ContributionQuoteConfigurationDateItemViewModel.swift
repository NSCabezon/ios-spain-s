import UIKit

class ContributionQuoteConfigurationDateItemViewModel: TableModelViewItem<PlanQuoteConfigurationDateItemTableViewCell>, DatePickerControllerConfiguration {
    
    var title: LocalizedStylableText
    var date: Date?
    var order: RoundedContainerItemOrder
    
    // DatePickerControllerConfiguration
    var lowerLimitDate: Date?
    var upperLimitDate: Date?
    
    init(title: LocalizedStylableText, date: Date, order: RoundedContainerItemOrder, privateComponent: PresentationComponent) {
        self.title = title
        self.date = date
        self.order = order
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: PlanQuoteConfigurationDateItemTableViewCell) {
        viewCell.title = title
        if let date = date {
            viewCell.date = formatDate(date: date)
        }
        viewCell.order = order
    }
}

extension ContributionQuoteConfigurationDateItemViewModel: DateSelectionViewModel {
    func formatDate(date: Date) -> String {
        return dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy) ?? ""
    }
    
    func dateDidChange() {}
}
