//

import UIKit

class StockDetailInfoWithoutImageTableViewCell: BaseViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var titleLabelString: LocalizedStylableText? {
        didSet {
            if let newStyle = titleLabelString {
                titleLabel.set(localizedStylableText: newStyle)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                           font: UIFont.latoRegular(size: 16),
                                           textAlignment: .left))
        
        backgroundColor = .clear
        selectionStyle = .none
    }
}
