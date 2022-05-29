//

import UIKit

struct PostItSummaryData {
    let field: LocalizedStylableText
    let value: String
    let isShareable = true
}

extension PostItSummaryData: SummaryItemData {
    func createSummaryItem() -> SummaryItem {
        return SummaryItemViewConfigurator<PostItSummaryItemView, PostItSummaryData>(data: self)
    }
    
    var description: String {
        return "\(field.text) \(value)"
    }
}

class PostItSummaryItemView: SummaryItemView, ConfigurableSummaryItemView {
    @IBOutlet weak var yellowView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        yellowView.backgroundColor = .yellowBackground
    }
    
    func configure(data: PostItSummaryData) {
        fieldLabel.set(localizedStylableText: data.field)
        valueLabel.text = data.value
    }
}
