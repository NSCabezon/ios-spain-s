import UIKit

public protocol OnItemProductGenericSelectProtocol {
    func onItemProductGenericSelected()
}

class ItemProductGenericViewCell: BasePgViewCell, ItemProductBaseViewProtocol, ItemProductGenericProtocol {

    @IBOutlet weak var content: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    @IBOutlet weak var transferCountCircleView: UIView!
    @IBOutlet weak var transferCountLabel: UILabel!
    @IBOutlet weak var transferCountWidth: NSLayoutConstraint!

    @IBOutlet weak var productGenericName: UILabel!
    @IBOutlet weak var productGenericSubName: UILabel!
    @IBOutlet weak var productGenericQuantity: UILabel!
    
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    private var usesBottomPadding: Bool = true
    var lastItem: Bool = false
    private var mProtocol: OnItemProductGenericSelectProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productGenericName.applyStyle(LabelStylist.pgProductName)
        productGenericSubName.applyStyle(LabelStylist.pgProductSubName)
        productGenericQuantity.applyStyle(LabelStylist.pgProductAmount)
        
        transferCountLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .latoBold(size: 10), textAlignment: .center))
        transferCountCircleView.layer.cornerRadius = transferCountCircleView.frame.size.width / 2
        transferCountCircleView.layer.masksToBounds = false
        transferCountCircleView.backgroundColor = .sanRed
        
        content.backgroundColor = .uiBackground
        bottomSeparator.layer.backgroundColor = UIColor.lisboaGray.cgColor
        selectionStyle = .none
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if lastItem {
            StylizerPGViewCells.applyBottomViewCellStyle(view: containerView)
        } else {
            StylizerPGViewCells.applyMiddleViewCellStyle(view: containerView)
        }
        
        if !usesBottomPadding {
            bottomPadding.constant = 0
        }
    }
    
    public func setUsesBottomPadding(value: Bool) {
        usesBottomPadding = value
    }
    
    public func setOnItemProductGenericSelectProtocol(_ mProtocol: OnItemProductGenericSelectProtocol) {
        self.mProtocol = mProtocol
    }
    
    func setName(name: String) {
        productGenericName.text = name
    }

    func setSubName(subName: String) {
        productGenericSubName.text = subName
    }
    
    func setQuantity(quantity: String) {
        productGenericQuantity.text = quantity
        productGenericQuantity.scaleDecimals()
    }
    
    func setTransferCount(count: String?) {
        if let count = count {
            transferCountWidth.constant = 25
            transferCountLabel.text = count
        } else {
            transferCountWidth.constant = 0
            transferCountLabel.text = nil
        }
    }
    
    func setBottomMode() {
        lastItem = true
        bottomSeparator.isHidden = true
    }

    func setMiddleMode() {
        lastItem = false
        bottomSeparator.isHidden = false
    }
    
    func setBackgroundColorCell(color: UIColor) {
        content.backgroundColor = color
    }

}
