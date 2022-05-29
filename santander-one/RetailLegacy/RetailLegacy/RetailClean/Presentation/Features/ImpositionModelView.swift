import Foundation

class ImpositionModelView: TableModelViewItem<ImpositionViewCell> {

    var imposition: Imposition
    var isFirstTransaction: Bool
    var showsDate: Bool = true
    
    init(_ imposition: Imposition, _ isFirst: Bool, _ privateComponent: PresentationComponent) {
        self.imposition = imposition
        self.isFirstTransaction = isFirst
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: ImpositionViewCell) {
        viewCell.showsDate = showsDate
        viewCell.isFirstTransaction = isFirstTransaction
        viewCell.month = dependencies.timeManager.toString(date: imposition.dueDate, outputFormat: .MMM)?.uppercased()
        viewCell.day = dependencies.timeManager.toString(date: imposition.dueDate, outputFormat: .d)
        viewCell.impositionNumber = dependencies.stringLoader.getString("deposits_label_number", [StringPlaceholder(StringPlaceholder.Placeholder.number, imposition.subcontract)])
        var tae: String = ""
        if let t = imposition.TAE {
            tae = t
        }
        viewCell.TAE = tae + "%"
        viewCell.transactionAmount = imposition.settlementAmount
    }
}

extension ImpositionModelView: DateProvider {
    
    var transactionDate: Date? {
        return imposition.dueDate
    }
    
    var shouldDisplayDate: Bool {
        get {
            return showsDate
        }
        set {
            showsDate = newValue
        }
    }
    
}
