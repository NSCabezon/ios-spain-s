import UIKit

extension OptionsStackView {

    class OptionButton: UIButton {
        
        var optionData: ValueOptionType? {
            didSet {
                optionData?.highlightAction = { [weak self] shouldHighlight in
                    self?.isHighlighted = shouldHighlight
                    self?.layer.borderColor = shouldHighlight ? self?.selectedColor.cgColor : self?.nonSelectedColor.cgColor
                    let titleColor = shouldHighlight ? self?.selectedColor : UIColor.sanGreyDark
                    self?.setTitleColor(titleColor, for: .normal)
                }
            }
        }
        
        var selectedColor = UIColor.sanRed
        var nonSelectedColor = UIColor.lisboaGray
    }
    
}
