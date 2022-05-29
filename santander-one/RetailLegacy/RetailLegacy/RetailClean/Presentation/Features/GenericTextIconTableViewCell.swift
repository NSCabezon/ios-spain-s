import UIKit

class GenericTextIconTableViewCell: GroupableTableViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: CoachmarkUILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var buttonAction: (() -> Void)? {
        didSet {
            buttonContainerView.isHidden = buttonAction.isNil
        }
    }
    
    var subtitleLabelCoachmarkId: CoachmarkIdentifier? {
        get {
            return self.subtitleLabel.coachmarkId
        } set {
            self.subtitleLabel.coachmarkId = newValue
        }
    }

    override var roundedView: UIView {
        return containerView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0)))
        (subtitleLabel as UILabel).applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14.0)))
        actionButton.applyStyle(ButtonStylist(textColor: .sanRed, font: .latoMedium(size: 13.0)))
        setupActionButton()
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func setSubtitle(_ subtitle: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: subtitle)
    }
    
    func setIcon(_ image: UIImage?) {
        iconImageView.image = image
    }
    
    func setButtonTitle(_ title: LocalizedStylableText?) {
        guard let title = title else { return }
        actionButton.set(localizedStylableText: title, state: .normal)
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        actionButton.layer.cornerRadius = actionButton.bounds.height / 2
    }
    
    fileprivate func setupActionButton() {
        actionButton.layer.borderWidth = 2.0
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        let redColor = UIColor.sanRed
        actionButton.layer.borderColor = redColor.cgColor
        actionButton.setTitleColor(redColor, for: .normal)
        actionButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        buttonAction?()
    }
}
