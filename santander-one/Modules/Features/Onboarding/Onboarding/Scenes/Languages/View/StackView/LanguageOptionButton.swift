import UIKit
import UI

class LanguageOptionButton: UIButton {
    var optionData: ValueOptionType? {
        didSet {
            optionData?.highlightAction = { [weak self] shouldHighlight in
                self?.isHighlighted = shouldHighlight
                self?.backgroundColor = shouldHighlight ? self?.selectedBackgroundColor : self?.nonSelectedBackgroundColor
                self?.layer.borderColor = shouldHighlight ? self?.selectedBorderColor.cgColor : self?.nonSelectedBorderColor.cgColor
                let titleColor = shouldHighlight ? self?.selectedTitleColor : self?.noSelectedTitleColor
                self?.setTitleColor(titleColor, for: .normal)
            }
        }
    }
    
    var selectedBackgroundColor: UIColor = UIColor.darkTorquoise
    var nonSelectedBackgroundColor: UIColor = UIColor.white
    var selectedBorderColor: UIColor = UIColor.darkTorquoise
    var nonSelectedBorderColor: UIColor = UIColor.mediumSky
    var selectedTitleColor: UIColor = UIColor.white
    var noSelectedTitleColor: UIColor = UIColor.lisboaGray
}
