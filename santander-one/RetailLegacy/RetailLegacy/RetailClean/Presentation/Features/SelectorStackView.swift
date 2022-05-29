import UIKit
import UI

class SelectorStackView: StackItemView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightArrow: UIImageView!
    var didSelect: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        rightArrow.image = Assets.image(named: "icnArrowRightRed")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.drawRoundedAndShadowed()
        
    }
    
    @IBAction func selectorPressed(_ sender: Any) {
        didSelect?()
    }
    
    func setPlaceholder(_ placeholder: LocalizedStylableText) {
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoSemibold(size: 16)))
        titleLabel.set(localizedStylableText: placeholder)
    }
    
    func setTitle(_ title: String?) {
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16)))
        titleLabel.text = title
    }
}
