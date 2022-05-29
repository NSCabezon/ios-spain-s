import UIKit
import UI

class PersonalAreaCMCStatusTableCell: SpaceGroupableTableViewCell {
    
    var title: LocalizedStylableText? {
        didSet {
            if let title = title {
                titleLabel.set(localizedStylableText: title)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var value: (text: LocalizedStylableText?, operative: Bool)? {
        didSet {
            if let text = value?.text {
                valueLabel.set(localizedStylableText: text)
                let operative = value?.operative ?? false
                setStatusColor(isOperative: operative)
            } else {
                valueLabel.text = nil
            }
        }
    }
    
    var iconButtonTouched: (() -> Void)?
    
    override var roundedView: UIView {
        return containerView
    }

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16.0)))
        valueLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 16.0)))
        iconView.image = Assets.image(named: "icnInfoGrayBig")
    }
    
    func showToolTip(description: LocalizedStylableText, inPresenter presenter: ToolTipablePresenter) {
        ToolTip.displayToolTip(title: nil,
                               description: nil,
                               descriptionLocalized: description,
                               sourceView: iconView,
                               sourceRect: iconView.bounds,
                               backView: presenter.toolTipBackView)
    }
    
    private func setStatusColor(isOperative: Bool) {
        valueLabel.textColor = isOperative ? UIColor.color(forDispositionStatus: .exempt) : .sanGreyMedium
    }
    
    @IBAction func iconButtonTouched(_ sender: UIButton) {
        iconButtonTouched?()
    }
}
