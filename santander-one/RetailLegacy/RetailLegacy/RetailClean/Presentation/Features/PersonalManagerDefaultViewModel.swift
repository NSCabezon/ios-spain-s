import UIKit

enum DefaultAction {
    case mail
    case date
    case chat
    case videoCall
}

class PersonalManagerDefaultViewModel: TableModelViewItem<PersonalManagerDefaultViewCell> {
    private let iconImage: String
    private let title: LocalizedStylableText
    private let subtitle: LocalizedStylableText
    private let buttonText: LocalizedStylableText
    private let isHiddenBottomView: Bool
    private let defaultAction: DefaultAction
    private weak var delegate: PersonalManagerDefaultDelegate?
    
    init(iconImage: String, title: LocalizedStylableText, subtitle: LocalizedStylableText, buttonText: LocalizedStylableText, isHiddenBottomView: Bool, action: DefaultAction, delegate: PersonalManagerDefaultDelegate, presentation: PresentationComponent) {
        self.iconImage = iconImage
        self.title = title
        self.subtitle = subtitle
        self.buttonText = buttonText
        self.isHiddenBottomView = isHiddenBottomView
        self.defaultAction = action
        self.delegate = delegate
        super.init(dependencies: presentation)
    }
    
    override func bind(viewCell: PersonalManagerDefaultViewCell) {
        viewCell.setImage = iconImage
        viewCell.titleLabel.set(localizedStylableText: title)
        viewCell.subtitleLabel.set(localizedStylableText: subtitle)
        viewCell.defaultButton.set(localizedStylableText: buttonText, state: .normal)
        viewCell.bottomSeparatorView.isHidden = isHiddenBottomView
        viewCell.delegate = delegate
        switch defaultAction {
        case .mail:
            viewCell.defaultButton.addTarget(viewCell, action: #selector(viewCell.mailButtonAction), for: .touchUpInside)
        case .date:
            viewCell.defaultButton.addTarget(viewCell, action: #selector(viewCell.dateAction), for: .touchUpInside)
        case .chat:
            viewCell.defaultButton.addTarget(viewCell, action: #selector(viewCell.chatAction), for: .touchUpInside)
        case .videoCall:
            viewCell.defaultButton.addTarget(viewCell, action: #selector(viewCell.videoCallAction), for: .touchUpInside)
        }
    }
}
