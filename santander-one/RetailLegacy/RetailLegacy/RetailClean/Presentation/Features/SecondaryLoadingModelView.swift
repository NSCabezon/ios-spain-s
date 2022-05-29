import Foundation

class SecondaryLoadingModelView: TableModelViewItem<SecondaryLoadingViewCell> {
    
    var showsDate: Bool = false
    var isFirstTransaction: Bool = false
    
    override  func bind(viewCell: SecondaryLoadingViewCell) {}
    
}

extension SecondaryLoadingModelView: DateProvider {
    
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
