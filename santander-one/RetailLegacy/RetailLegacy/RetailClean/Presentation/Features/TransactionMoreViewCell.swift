import UIKit
import UI

protocol TransactionMoreViewCellDelegate: class {
    func transactionMoreViewCellDidTouched()
}

class TransactionMoreViewCell: BaseViewCell {
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var arrowImage: UIImageView!
    weak var delegate: TransactionMoreViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moreLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoSemibold(size: 14), textAlignment: .center))
        separator.backgroundColor = .lisboaGray
        arrowImage.image = Assets.image(named: "icnArrowDownRed")
    }
    
    func set(title: LocalizedStylableText) {
        moreLabel.set(localizedStylableText: title)
    }
    
    @IBAction func buttonAction(_ sender: UIControl) {
        delegate?.transactionMoreViewCellDidTouched()
    }
}
