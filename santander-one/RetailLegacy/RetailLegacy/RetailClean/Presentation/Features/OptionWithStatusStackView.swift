import UIKit

class OptionWithStatusStackView: StackItemView, RoundCapableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkImageView: UIImageView!
    var executeAction: (() -> Void)?
    
    var roundedView: UIView! {
        return containerView
    }
    var isFirst = false {
        didSet {
            separatorView.isHidden = isFirst == true
        }
    }
    var isLast = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyRoundedStyle()
    }
    
    private func setupViews() {
        separatorView.backgroundColor = .lisboaGray
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 13)))
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func setSubtitle(_ subtitle: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: subtitle)
    }
    
    func setChecked(_ isChecked: Bool) {
        checkImageView.isHidden = !isChecked
    }
    
    @IBAction func optionPressed(_ sender: Any) {
        executeAction?()
    }
    
}
