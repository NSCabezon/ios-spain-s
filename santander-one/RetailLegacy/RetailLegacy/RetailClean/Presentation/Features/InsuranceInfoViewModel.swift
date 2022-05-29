import Foundation

class InsuranceInfoViewModel: TableModelViewItem<InsuranceInfoTableViewCell> {
    
    var isFirst: Bool
    var isLast: Bool
    var infoTitle: String
    var info: String
    var showsDate: Bool = false
    var isFirstTransaction: Bool = false
    
    init(isFirst: Bool, isLast: Bool, infoTitle: String, info: String, privateComponent: PresentationComponent) {
        self.isFirst = isFirst
        self.isLast = isLast
        self.infoTitle = infoTitle
        self.info = info
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: InsuranceInfoTableViewCell) {
        viewCell.isFirst = isFirst
        viewCell.isLast = isLast
        viewCell.infoTitle = infoTitle
        viewCell.info = info
    }
}

extension InsuranceInfoViewModel: DateProvider {
    
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
