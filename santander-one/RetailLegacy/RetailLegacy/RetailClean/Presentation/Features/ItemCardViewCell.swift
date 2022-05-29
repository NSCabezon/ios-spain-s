import UIKit

 protocol OnItemCardSelectProtocol {
    func onItemCardSelected()
}

class ItemCardViewCell: BasePgViewCell, ItemProductBaseViewProtocol, ItemProductGenericProtocol {
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var cardAccount: UILabel!
    @IBOutlet weak var cardItemQuantityTitle: UILabel!
    @IBOutlet weak var cardItemQuantity: UILabel!
    @IBOutlet weak var cardItemImageView: UIImageView!
    @IBOutlet weak var labelsContainerView: UIView!
    @IBOutlet weak var activateButton: UIButton!
    @IBOutlet weak var transferCountCircleView: UIView!
    @IBOutlet weak var transferCountLabel: UILabel!
   
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    private var usesBottomPadding: Bool = true
    private var lastItem: Bool = false
    private var mProtocol: OnItemCardSelectProtocol!
    
    var didSelectActivate: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardName.applyStyle(LabelStylist.pgProductName)
        cardAccount.applyStyle(LabelStylist.pgProductSubName)
        cardItemQuantityTitle.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0)))
        cardItemQuantity.applyStyle(LabelStylist.pgProductAmount)
        
        content.backgroundColor = .uiBackground
        bottomSeparator.layer.backgroundColor = UIColor.lisboaGray.cgColor
        
        transferCountLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .latoBold(size: 10), textAlignment: .center))
        transferCountCircleView.layer.cornerRadius = transferCountCircleView.frame.size.width / 2
        transferCountCircleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        transferCountCircleView.layer.shadowOpacity = 0.5
        transferCountCircleView.layer.shadowColor = UIColor.uiBlack.cgColor
        transferCountCircleView.layer.shadowRadius = 2
        transferCountCircleView.backgroundColor = .sanRed
        
        selectionStyle = .none
        setupActivateButton()
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
    
    func setTransferCount(count: String?) {
        transferCountLabel.text = count
        transferCountCircleView.isHidden = count == nil
    }
    
    func setBackgroundColorCell(color: UIColor) {
        content.backgroundColor = color
    }
    
    func setOnItemCardSelectProtocol(_ mProtocol: OnItemCardSelectProtocol) {
        self.mProtocol = mProtocol
    }
    
     func setName(name: String) {
        cardName.text = name
    }
    
     func setSubName(subName: String) {
        cardAccount.text = subName
    }
    
    func setStyledSubName(subname: LocalizedStylableText) {
        cardAccount.set(localizedStylableText: subname)
    }
    
     func setQuantity(quantity: String) {
        cardItemQuantity.text = quantity
        cardItemQuantity.scaleDecimals()
    }
    
     func setQuantityTitle(_ quantityTitle: LocalizedStylableText) {
        cardItemQuantityTitle.set(localizedStylableText: quantityTitle)
    }
    
     func getCardImageView() -> UIImageView {
        return cardItemImageView
    }
    
     func setCardImageAlpha(_ alpha: Float) {
        //cardItemImageView.setAlpha(alpha);
    }
    
     func setTextColor(_ color: Int) {
        //cardName.setTextColor(color);
    }
    
    func setActivateTitle(_ title: LocalizedStylableText) {
        activateButton.set(localizedStylableText: title, state: .normal) { [weak self] in
            if let activateButton = self?.activateButton {
                activateButton.sizeToFit()
            }
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

    func isGrayedOut(_ isGrayedOut: Bool) {
        labelsContainerView.alpha = isGrayedOut ? 0.4 : 1.0
    }
    
    func isActivatePending(_ isActive: Bool) {
        cardItemQuantityTitle.isHidden = isActive
        cardItemQuantity.isHidden = isActive
        activateButton.isHidden = !isActive
    }

    fileprivate func setupActivateButton() {
        activateButton.layer.borderWidth = 2.0
        activateButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        let redColor = UIColor.sanRed
        activateButton.layer.borderColor = redColor.cgColor
        activateButton.setTitleColor(redColor, for: .normal)
    }
    
    @IBAction func activatePressed(_ sender: UIButton) {
        didSelectActivate?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activateButton.layer.cornerRadius = activateButton.bounds.height / 2
    }
}
