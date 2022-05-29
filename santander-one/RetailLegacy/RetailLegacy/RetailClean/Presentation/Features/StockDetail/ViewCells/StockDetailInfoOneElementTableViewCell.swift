//

import UIKit

class StockDetailInfoOneElementTableViewCell: BaseViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstValueLabel: UILabel!
    
    var firstTitleLabelString: LocalizedStylableText? {
        didSet {
            if let newStyle = firstTitleLabelString {
                titleLabel.set(localizedStylableText: newStyle)
            }
        }
    }
    
    var firstValueLabelString: String {
        set {
            firstValueLabel.text = newValue
        }
        get {
            return firstValueLabel.text ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                font: UIFont.latoLight(size: 16),
                                                textAlignment: .left))
        
        firstValueLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                font: UIFont.latoSemibold(size: 16),
                                                textAlignment: .left))
        
        backgroundColor = .clear
        selectionStyle = .none
    }
}
