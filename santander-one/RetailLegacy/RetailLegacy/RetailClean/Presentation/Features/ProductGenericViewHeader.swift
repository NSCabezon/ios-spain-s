import UIKit
import UI

class ProductGenericViewHeader: BaseViewHeader {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var transfersLabel: UILabel!
    @IBOutlet weak var totalTransfers: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.applyStyle(LabelStylist.pgBasketTitle)
        subLabel.applyStyle(LabelStylist.pgBasketAmountLabel)
        totalAmount.applyStyle(LabelStylist.pgBasketAmountValue)
        
        transfersLabel.applyStyle(LabelStylist.pgBasketAmountLabel)
        totalTransfers.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 15)))

        view.backgroundColor = .uiBackground
    }

    override func getContainerView() -> UIView? {
        return containerView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        totalAmount.applyStyle(LabelStylist.pgBasketAmountValue)
    }
    
    override func draw() {
        if collapsed {
            arrowImageView.image = Assets.image(named: "icnArrowDownPG")
            StylizerPGViewCells.applyHeaderCloseViewCellStyle(view: containerView)
        } else {
            arrowImageView.image = Assets.image(named: "icnArrowUpPG")
            StylizerPGViewCells.applyHeaderOpenViewCellStyle(view: containerView)
        }
    }
        
    func setLabel(label: LocalizedStylableText) {
        self.label.set(localizedStylableText: label)
        isAccessibilityElement = true
        accessibilityIdentifier = "Section-" + label.text
    }

    func setSubLabel(subLabel: LocalizedStylableText) {
        self.subLabel.set(localizedStylableText: subLabel)
    }
    
    func setTotalAmount(totalAmount: String) {
        self.totalAmount.text = totalAmount
        self.totalAmount.scaleDecimals()
        subLabel.isHidden = false
    }
    
    func setMultipleCurrency(totalAmount: LocalizedStylableText) {
        self.totalAmount.font = self.totalAmount.font.withSize(CGFloat(15.0))
        self.totalAmount.set(localizedStylableText: totalAmount)
        subLabel.isHidden = true
    }
    
    func setTotalTransfers(totalTransfers: String?) {
        self.totalTransfers.text = totalTransfers
    }

    func setTransfersLabel(transfersLabel: LocalizedStylableText?) {
        if let text = transfersLabel {
            self.transfersLabel.set(localizedStylableText: text)
        } else {
            self.transfersLabel.text = nil
        }
    }
    
    func setBackgroundColorCell(color: UIColor) {
        view.backgroundColor = color
    }
    
    func hideAllExceptTitle() {
        subLabel.isHidden = true
        transfersLabel.isHidden = true
        totalTransfers.isHidden = true
        arrowImageView.isHidden = true
        totalAmount.isHidden = true
    }
    
    func showAll() {
        subLabel.isHidden = false
        transfersLabel.isHidden = false
        totalTransfers.isHidden = false
        arrowImageView.isHidden = false
        totalAmount.isHidden = false
    }
}
