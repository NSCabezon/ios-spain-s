//

import UIKit

protocol LinkSummaryItemDelegate: class {
    func selectedLink(tag: Int)
}

struct LinkSummaryItemData {
    let field: LocalizedStylableText
    let tag: Int
    var delegate: LinkSummaryItemDelegate?
    let isShareable = false
}

extension LinkSummaryItemData: SummaryItemData {
    func createSummaryItem() -> SummaryItem {
        return SummaryItemViewConfigurator<LinkSummaryItemView, LinkSummaryItemData>(data: self)
    }
    
    var description: String {
        return ""
    }
}

class LinkSummaryItemView: UIView, ConfigurableSummaryItemView {
    @IBOutlet weak var fieldLabel: UILabel!
    private var linkTag: Int = 0
    var linkDelegate: LinkSummaryItemDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        fieldLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoRegular(size: 14.0)))
        fieldLabel.sizeToFit()
        backgroundColor = .clear
    }
    
    @IBAction func actionLink(_ sender: Any) {
        linkDelegate?.selectedLink(tag: linkTag)
    }
    
    func configure(data: LinkSummaryItemData) {
        linkTag = data.tag
        linkDelegate = data.delegate
        fieldLabel.set(localizedStylableText: data.field)
    }
}
