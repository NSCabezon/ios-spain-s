import UIKit

class MaxMinCellItem: BaseViewCell {
    
    @IBOutlet weak var labelText: UILabel!
    
    var labelTextString: LocalizedStylableText? {
        didSet {
            if let localized = labelTextString {
                labelText.set(localizedStylableText: localized)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        labelText.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 14), textAlignment: .left))
    }
}
