import UIKit

enum RoundedContainerItemOrder {
    case head
    case middle
    case tail
}

class ContributionQuoteConfigurationItemViewModel: TableModelViewItem<PlanQuoteConfigurationItemTableViewCell> {
    
    var title: LocalizedStylableText
    var value: String
    var order: RoundedContainerItemOrder
    
    init(title: LocalizedStylableText, value: String, order: RoundedContainerItemOrder, privateComponent: PresentationComponent) {
        self.title = title
        self.value = value
        self.order = order
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: PlanQuoteConfigurationItemTableViewCell) {
        viewCell.title = title
        viewCell.value = value
        viewCell.order = order
    }
}
