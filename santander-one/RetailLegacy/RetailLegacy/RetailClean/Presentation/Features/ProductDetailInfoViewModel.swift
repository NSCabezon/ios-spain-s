import Foundation

class ProductDetailInfoViewModel: TableModelViewItem<ProductDetailInfoCell> {
    
    public enum InteractionableTextLabelType {
        case notInteractive
        case copiable
        case editable
    }
    
    var isFirst: Bool
    var interactionableTextLabelType: InteractionableTextLabelType
    var isAfterEditableCell: Bool
    var infoTitle: LocalizedStylableText
    var info: String?
    var infoStylable: LocalizedStylableText?
    var copyTag: Int?
    var showsDate: Bool = false
    var isFirstTransaction: Bool = false
    let valueColor: ItemViewColor?
    weak var shareDelegate: ShareInfoHandler?
    
    init(interactionableTextLabelType: InteractionableTextLabelType = .notInteractive, isAfterEditableCell: Bool = false, infoTitle: LocalizedStylableText, info: String? = nil, infoStylable: LocalizedStylableText? = nil, privateComponent: PresentationComponent, copyTag: Int? = nil, valueColor: ItemViewColor? = nil, shareDelegate: ShareInfoHandler?) {
        self.isFirst = false
        self.interactionableTextLabelType = interactionableTextLabelType
        self.isAfterEditableCell = isAfterEditableCell
        self.infoTitle = infoTitle
        self.info = info
        self.infoStylable = infoStylable
        self.copyTag = copyTag
        self.valueColor = valueColor
        self.shareDelegate = shareDelegate
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: ProductDetailInfoCell) {
        viewCell.isFirst = isFirst
        viewCell.isCopiable = interactionableTextLabelType == .copiable
        viewCell.isEditable = interactionableTextLabelType == .editable
        viewCell.calculateSeparatorEdges(isAfterEditableCell: isAfterEditableCell)
        viewCell.infoTitle = infoTitle
        if let text = infoStylable {
            viewCell.infoStylable = text
        } else {
            viewCell.info = info
        }
        if let valueColor = valueColor {
            viewCell.set(color: valueColor)
        }
        viewCell.tag = copyTag ?? 0
        viewCell.shareDelegate = shareDelegate
    }
}

extension ProductDetailInfoViewModel: DateProvider {
    
    var transactionDate: Date? {
        return nil
    }
    
    var shouldDisplayDate: Bool {
        get {
            return false
        }
        set {
            showsDate = newValue
        }
    }
    
}

protocol ColorableItemView {
    func set(color: ItemViewColor)
}

protocol ItemViewColor {
    func drawIn(value: ColorableItemView)
}
