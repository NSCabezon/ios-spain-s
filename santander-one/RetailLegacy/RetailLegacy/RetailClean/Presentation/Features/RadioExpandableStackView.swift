import UIKit

class RadioExpandableStackView: StackItemView {
    
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        roundedView.backgroundColor = .uiWhite
    }
    
    func addView(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundedView.drawRoundedAndShadowed()
    }
    
}
