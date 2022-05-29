import Foundation

class InsuranceGeneralDataViewModel: TableModelViewItem<InsuranceGeneralDataTableViewCell> {
    
    var isFirst: Bool
    var isLast: Bool
    var isCopiable: Bool
    var infoTitle: LocalizedStylableText
    var info: String
    var showsDate: Bool = false
    var isFirstTransaction: Bool = false
    var copyTag: Int?
    weak var shareDelegate: ShareInfoHandler?
    
    init(isFirst: Bool, isLast: Bool, isCopiable: Bool, infoTitle: LocalizedStylableText, info: String, privateComponent: PresentationComponent, copyTag: Int? = nil, shareDelegate: ShareInfoHandler) {
        self.isFirst = isFirst
        self.isLast = isLast
        self.isCopiable = isCopiable
        self.infoTitle = infoTitle
        self.info = info
        self.copyTag = copyTag
        self.shareDelegate = shareDelegate
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: InsuranceGeneralDataTableViewCell) {
        viewCell.isFirst = isFirst
        viewCell.isLast = isLast
        viewCell.isCopiable = isCopiable
        viewCell.infoTitle = infoTitle
        viewCell.info = info
        viewCell.tag = copyTag ?? 0
        viewCell.shareDelegate = shareDelegate
    }
}

extension InsuranceGeneralDataViewModel: DateProvider {
    
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
