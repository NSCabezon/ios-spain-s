//

import UIKit

class PINNumberView: UIView {
    
    @IBOutlet weak var numberLabel: UILabel!
    
    func setup() {
        numberLabel.applyStyle(LabelStylist(textColor: .darkGray, font: .latoBold(size: 34), textAlignment: .center))
        drawBorder(cornerRadius: 5.0, color: .lisboaGray)
        numberLabel.accessibilityIdentifier = "pinQuery_labelNumber"
    }
}
