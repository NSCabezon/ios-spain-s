import UIKit
import UI

class TitleLabelInfoStackView: StackItemView {
    var tooltipText: LocalizedStylableText?
    var tooltipTitle: LocalizedStylableText?
    weak var actionDelegate: TooltipTextFieldActionDelegate?
    @IBOutlet weak var tooltipButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16), textAlignment: .left))
        tooltipButton.setImage(Assets.image(named: "icnInfoGrayBig"), for: .normal)
    }
    
    func setTitle(title: LocalizedStylableText, accessibilityIdentifier: String? = nil) {
        titleLabel.set(localizedStylableText: title)
        self.titleLabel.accessibilityIdentifier = accessibilityIdentifier
    }
    
    @IBAction func showToolTip() {
        actionDelegate?.auxiliaryButtonAction(completion: { [weak self] (action) in
            switch action {
            case .toolTip(let delegate):
                guard let strongSelf = self else { return }
                delegate?.displayPermanentToolTip(with: strongSelf.tooltipTitle, descriptionLocalized: strongSelf.tooltipText, inView: strongSelf.tooltipButton, withSourceRect: strongSelf.tooltipButton.bounds, forcedDirection: [.up, .down])
            default:
                break
            }
        })
    }
}
