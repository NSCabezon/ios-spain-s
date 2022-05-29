import UIKit

class WhatsAppTableViewCell: GroupableTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var copyButton: UIButton!
    var buttonAction: (() -> Void)?
    weak var tooltipDisplayer: ToolTipDisplayer?
    weak var copyDelegate: CopiableInfoHandler?

    override var roundedView: UIView {
        return containerView
    }
    
    func setTitle(_ title: LocalizedStylableText?) {
        guard let title = title else { return }
        titleLabel.set(localizedStylableText: title)
    }

    func setSubtitle(_ subtitle: LocalizedStylableText?) {
        guard let subtitle = subtitle else { return }
        subtitleLabel.set(localizedStylableText: subtitle)
    }
    
    func setPhone(_ phone: String) {
        phoneLabel.text = phone
    }
    
    func setButtonTitle(_ title: LocalizedStylableText?) {
        guard let title = title else { return }
        copyButton.set(localizedStylableText: title, state: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
        phoneLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoBold(size: 28.0)))
        setupCopyButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        copyButton.layer.cornerRadius = copyButton.bounds.height/2
    }
    
    fileprivate func setupCopyButton() {
        copyButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        copyButton.applyStyle(ButtonStylist(textColor: .sanRed, font: .latoMedium(size: 13), borderColor: .sanRed, borderWidth: 2))
        copyButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    func displayCopiedTooltip() {
        copyDelegate?.copyDescription(tag: self.tag, completion: { (title, description) in
            tooltipDisplayer?.displayToolTip(with: title, description: description, inView: self, withSourceRect: copyButton.frame)
        })
    }
    
    @objc func buttonPressed() {
        displayCopiedTooltip()
    }
}
