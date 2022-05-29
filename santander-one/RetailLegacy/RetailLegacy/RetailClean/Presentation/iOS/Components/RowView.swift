import UIKit

extension ButtonStackView {
    
    class RowView: UIStackView {
        
        func addOption(_ option: TransactionDetailActionType) {
            let optionView = OptionView()
            optionView.config(option)
            addArrangedSubview(optionView)
        }
        
        func addOptions(_ options: [TransactionDetailActionType]) {
            for v in arrangedSubviews {
                removeArrangedSubview(v)
                v.removeFromSuperview()
            }
            
            for option in options {
                addOption(option)
            }
        }
        
        var itemCount: Int {
            return arrangedSubviews.count
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            for v in arrangedSubviews {
                v.drawRoundedAndShadowed()
            }
        }
        
    }
}
