import UIKit
import UI

class TitledInfoTableHeader: BaseViewHeader {
    var title: LocalizedStylableText? {
        didSet {
            if let text = title {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    var tooltipText: LocalizedStylableText?
    var tooltipTitle: LocalizedStylableText?
    weak var actionDelegate: TooltipTextFieldActionDelegate?
    @IBOutlet weak var tooltipButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0)))
        backView.backgroundColor = .uiBackground
        tooltipButton.setImage(Assets.image(named: "icnInfoGrayBig"), for: .normal)
    }
    
    override func getContainerView() -> UIView? {
        return nil
    }
    
    override func draw() {
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
