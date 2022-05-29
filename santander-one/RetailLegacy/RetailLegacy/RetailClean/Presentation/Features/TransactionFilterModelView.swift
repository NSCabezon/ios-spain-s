import Foundation

protocol FilterManager: class {
    func filter()
}

class TransactionFilterModelView: TableModelViewItem<TransactionFilterViewCell> {
    
    private(set) var text: LocalizedStylableText?
    weak var filterManager: FilterManager?
    var showsFilter: Bool
    var showsDate: Bool = false
    var isFirstTransaction: Bool = false
    var isClearAvailable = false
    var didSelectClearFilter: (() -> Void)?
    var showPdfAction: (() -> Void)?
    
    public var filterButtonCoachmarkId: CoachmarkIdentifier?
    
    init(_ text: LocalizedStylableText?, _ privateComponent: PresentationComponent, _ filterManager: FilterManager?, _ showsFilter: Bool) {
        self.text = text
        self.filterManager = filterManager
        self.showsFilter = showsFilter
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: TransactionFilterViewCell) {
        viewCell.isFilterAvailable = self.showsFilter
        viewCell.title = self.text
        viewCell.didSelectFilter = { [weak self] in
            self?.filterManager?.filter()
        }
        viewCell.didSelectClear = { [weak self] in
            self?.didSelectClearFilter?()
        }
        viewCell.isClearAvailable = isClearAvailable
        viewCell.filterButtonCoachmarkId = filterButtonCoachmarkId
        
        viewCell.isPdfAvailable = showPdfAction != nil
        viewCell.didSelectPDF = { [weak self] in
            self?.showPdfAction?()
        }
    }
    
    func update(with text: LocalizedStylableText?) {
        self.text = text
    }
}

extension TransactionFilterModelView: DateProvider {
    
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
