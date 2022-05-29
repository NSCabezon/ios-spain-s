//

import UIKit

class StockDetailInfoTwoElementsTableViewCell: BaseViewCell {
    
    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var firstValueLabel: UILabel!
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var secondValueLabel: UILabel!

    var firstTitleLabelString: LocalizedStylableText? {
        didSet {
            if let newStyle = firstTitleLabelString {
                firstTitleLabel.set(localizedStylableText: newStyle)
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
    
    var secondTitleLabelString: LocalizedStylableText? {
        didSet {
            if let newStyle = secondTitleLabelString {
                secondTitleLabel.set(localizedStylableText: newStyle)
            }
        }
    }
    
    var secondValueLabelString: String {
        set {
            secondValueLabel.text = newValue
        }
        get {
            return secondValueLabel.text ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        firstTitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                           font: UIFont.latoLight(size: 16),
                                           textAlignment: .left))
        
        secondTitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                font: UIFont.latoLight(size: 16),
                                                textAlignment: .right))
        
        firstValueLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                font: UIFont.latoSemibold(size: 16),
                                                textAlignment: .left))
        
        secondValueLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                                 font: UIFont.latoSemibold(size: 16),
                                                 textAlignment: .right))
        
        backgroundColor = .clear
        selectionStyle = .none
    }
}
