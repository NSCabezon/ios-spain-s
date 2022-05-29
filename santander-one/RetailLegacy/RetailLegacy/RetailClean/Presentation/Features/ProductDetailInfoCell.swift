//

import UIKit
import UI

class ProductDetailInfoCell: BaseViewCell, ProductDetailCell, ToolTipCompatible {
    private let shortSeparatorConstraintConstant: CGFloat = 12
    private let longSeparatorConstraintConstant: CGFloat = 0

    @IBOutlet weak var colorableView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var shortSeparator: UIView!
    @IBOutlet weak var shortSeparatorLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var shortSeparatorRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    weak var toolTipDelegate: ToolTipDisplayer?
    weak var editDelegate: ProductDetailInfoDataSourceDelegate?
    weak var shareDelegate: ShareInfoHandler?
    
    private enum Constants {
        static let copyButtonImage = "icShareIban"
        static let editButtonImage = "icnEdit"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        copyButton.setImage(Assets.image(named:  Constants.copyButtonImage), for: .normal)
        editButton.setImage(Assets.image(named:  Constants.editButtonImage), for: .normal)
    }

    var isFirst: Bool = false {
        didSet {
            showSeparator()
        }
    }
    
    var isCopiable: Bool = false {
        didSet {
            showCopy()
        }
    }
    
    var isEditable: Bool = false {
        didSet {
            showEdit()
        }
    }
    
    var infoTitle: LocalizedStylableText? {
        didSet {
            if let text = infoTitle {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var info: String? {
        get {
            return infoLabel.text
        }
        
        set {
            infoLabel.text = newValue
        }
    }
    
    var infoStylable: LocalizedStylableText? {
        didSet {
            if let text = infoStylable {
                infoLabel.set(localizedStylableText: text)
            } else {
                infoLabel.text = nil
            }
        }
    }
    
    override func configureStyle() {
        super.configureStyle()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 16.0)))
        infoLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 18.0)))
        shortSeparator.backgroundColor = .lisboaGray
        backgroundColor = .clear
        colorableView.backgroundColor = backgroundColor
    }
    
    func calculateSeparatorEdges(isAfterEditableCell needsLongSeparator: Bool) {
        let newConstant = needsLongSeparator ? longSeparatorConstraintConstant: shortSeparatorConstraintConstant
        shortSeparatorLeftConstraint.constant = newConstant
        shortSeparatorRightConstraint.constant = newConstant
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        shareDelegate?.shareInfoWithCode(self.tag)
    }
    
    @IBAction func editPressed(_ sender: Any) {
        editDelegate?.edit()
    }
}

extension ProductDetailInfoCell: ColorableItemView {
    func set(color: ItemViewColor) {
        color.drawIn(value: self)
    }
}

struct DispensationStatusItemViewColor: ItemViewColor {
    let status: DispensationStatus
    
    func drawIn(value: ColorableItemView) {
        if let detailInfoCell = value as? ProductDetailInfoCell {
            detailInfoCell.infoLabel.textColor = UIColor.color(forDispositionStatus: status)
        }
    }
}

struct OperationCodeItemViewColor: ItemViewColor {
    
    func drawIn(value: ColorableItemView) {
        if let detailInfoCell = value as? ProductDetailInfoCell {
            detailInfoCell.colorableView.backgroundColor = .yellowBackground
        }
    }
}
