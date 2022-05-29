import UIKit
import UI

class NavigationBarView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var screenStatusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    var title: LocalizedStylableText? {
        didSet {
            guard let title = title else { return }
            titleLabel.set(localizedStylableText: title)
            titleLabel.sizeToFit()
        }
    }
    
    func setup() {
        titleLabel.adjustsFontSizeToFitWidth = true
        let style = LabelStylist(textColor: .santanderRed, font: .santanderHeadlineBold(size: 16), textAlignment: .right)
        titleLabel.applyStyle(style)
        closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
        closeButton.tintColor = .santanderRed
        self.backgroundColor = UIColor.clear
    }
}
