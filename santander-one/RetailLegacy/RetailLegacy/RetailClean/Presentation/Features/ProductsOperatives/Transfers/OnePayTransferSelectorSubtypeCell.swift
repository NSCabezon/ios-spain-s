import UIKit
import UI

class OnePayTransferSelectorSubtypeCell: BaseViewCell, ToolTipCompatible {
    
    @IBOutlet private weak var iconImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    weak var toolTipDelegate: ToolTipDisplayer?
    private var tooltipInfo: (title: LocalizedStylableText?, subtitle: LocalizedStylableText?) {
        didSet {
            infoButton.isHidden = tooltipInfo.title == nil && tooltipInfo.subtitle == nil
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        stackView.backgroundColor = .clear
        selectionStyle = .none
        containerView.drawRoundedAndShadowed()
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 15)))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let subViews = stackView.arrangedSubviews
        for subview in subViews {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
    
    func setTitle(text: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: text)
    }
    
    func setIcon(icon: String) {
        iconImage.image = Assets.image(named: icon)
    }
    
    func setToolTipWith(title: LocalizedStylableText?, subtitle: LocalizedStylableText?) {
        tooltipInfo = (title, subtitle)
    }
    
    func setContent(texts: [LocalizedStylableText]) {
        for text in texts {
            let circleLabel = UILabel()
            circleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoRegular(size: 14)))
            circleLabel.text = "•"
            let textLabel = UILabel()
            textLabel.numberOfLines = 0
            textLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14)))
            textLabel.set(localizedStylableText: text)
            let horizontalStackView = UIStackView(arrangedSubviews: [circleLabel, textLabel])
            horizontalStackView.axis = .horizontal
            horizontalStackView.alignment = .firstBaseline
            horizontalStackView.distribution = .equalSpacing
            horizontalStackView.backgroundColor = .clear
            stackView.addArrangedSubview(horizontalStackView)
            let width = NSLayoutConstraint(item: circleLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 14)
            width.priority = .required
            width.isActive = true
            let top = NSLayoutConstraint(item: horizontalStackView, attribute: .top, relatedBy: .equal, toItem: circleLabel, attribute: .top, multiplier: 1, constant: 0)
            top.priority = .required
            top.isActive = true
            let rigth = NSLayoutConstraint(item: circleLabel, attribute: .right, relatedBy: .equal, toItem: textLabel, attribute: .left, multiplier: 1, constant: 0)
            rigth.priority = .required
            rigth.isActive = true
        }
        layoutSubviews()
    }
    
    @IBAction func informationButtonPressed(_ sender: UIButton) {
        let rect = convert(sender.bounds, from: sender)
        toolTipDelegate?.displayPermanentToolTip(with: tooltipInfo.title, descriptionLocalized: tooltipInfo.subtitle, inView: self, withSourceRect: rect, forcedDirection: .up)
    }
}
