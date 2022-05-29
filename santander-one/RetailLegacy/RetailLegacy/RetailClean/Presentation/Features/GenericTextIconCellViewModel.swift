import UIKit
import UI

class GenericTextIconCellViewModel: GroupableCellViewModel<GenericTextIconTableViewCell> {
    
    var titleText: LocalizedStylableText
    var subtitleText: LocalizedStylableText
    var buttonTitle: LocalizedStylableText?
    var buttonAction: (() -> Void)?
    var icon: Icon?
    var subtitleLabelCoachmarkId: CoachmarkIdentifier?
    
    init(title: LocalizedStylableText, subtitle: LocalizedStylableText, icon: Icon?, dependencies: PresentationComponent, buttonTitle: LocalizedStylableText?, buttonAction: (() -> Void)?) {
        self.titleText = title
        self.subtitleText = subtitle
        self.buttonAction = buttonAction
        self.icon = icon
        self.buttonTitle = buttonTitle
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: GenericTextIconTableViewCell) {
        super.bind(viewCell: viewCell)
        viewCell.setTitle(titleText)
        viewCell.setSubtitle(subtitleText)
        if let image = icon?.image {
            viewCell.setIcon(image)
        }
        viewCell.buttonAction = buttonAction
        viewCell.setButtonTitle(buttonTitle)
        viewCell.subtitleLabelCoachmarkId = subtitleLabelCoachmarkId
    }
}

extension GenericTextIconCellViewModel {
    enum Icon {
        case chat
        case help
        case email
        case appointment
        
        var image: UIImage? {
            switch self {
            case .chat:
                return Assets.image(named: "icnChatAgent")
            case .help:
                return Assets.image(named: "icnVirtualAssistant")
            case .email:
                return Assets.image(named: "icnSendEmail")
            case .appointment:
                return Assets.image(named: "icnAskMeeting")
            }
        }
    }
}
