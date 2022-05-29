//

import UIKit

protocol ImpositionsLiquidationViewCellDelegate: class {
    func viewCellDidTouched(at index: Int)
}

class ImpositionLiquidationViewCell: BaseViewCell {
    
    @IBOutlet weak var initialDateLabel: UILabel!
    @IBOutlet weak var initialDateInfoLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDateInfoLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    weak var delegate: ImpositionsLiquidationViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialDateLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 15), textAlignment: .left))
        initialDateInfoLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoSemibold(size: 15), textAlignment: .left))
        endDateLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 15), textAlignment: .left))
        endDateInfoLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoSemibold(size: 15), textAlignment: .left))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 24), textAlignment: .left))
        separator.backgroundColor = .lisboaGray
    }
    
    @IBAction func liquidationAction(_ sender: UIControl) {
        delegate?.viewCellDidTouched(at: sender.tag)
    }
}
