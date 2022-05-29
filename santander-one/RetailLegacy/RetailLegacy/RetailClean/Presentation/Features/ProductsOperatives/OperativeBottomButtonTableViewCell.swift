//

import UIKit

class OperativeBottomButtonTableViewCell: BaseViewCell {

    @IBOutlet weak var button: RedButton!
    var buttonTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        button.configureHighlighted(font: .latoBold(size: 16))
    }
    
    var styledText: LocalizedStylableText? {
        didSet {
            guard let text = styledText else {
                button.setTitle(nil, for: .normal)
                return
            }
            button.set(localizedStylableText: text, state: .normal)
        }
    }
    
    @IBAction func touchButton(_ sender: Any) {
        buttonTapped?()
    }
}
