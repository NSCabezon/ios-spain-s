import UIKit

class WhatsAppCellViewModel: GroupableCellViewModel<WhatsAppTableViewCell> {
    
    var titleText: LocalizedStylableText?
    var subtitleText: LocalizedStylableText?
    var phone: String
    var buttonTitle: LocalizedStylableText?
    weak var tooltipDisplayer: ToolTipDisplayer?
    weak var copyDelegate: CopiableInfoHandler?
    
    init(title: LocalizedStylableText?, subtitle: LocalizedStylableText?, phone: String, dependencies: PresentationComponent, buttonTitle: LocalizedStylableText?, copyDelegate: CopiableInfoHandler?) {
        self.titleText = title
        self.subtitleText = subtitle
        self.phone = phone
        self.buttonTitle = buttonTitle
        self.copyDelegate = copyDelegate
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: WhatsAppTableViewCell) {
        super.bind(viewCell: viewCell)
        viewCell.setTitle(titleText)
        viewCell.setSubtitle(subtitleText)
        viewCell.setPhone(phone)
        viewCell.setButtonTitle(buttonTitle)
        viewCell.tooltipDisplayer = tooltipDisplayer
        viewCell.copyDelegate = copyDelegate
    }
        
}
