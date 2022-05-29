import UIKit

protocol SummaryItem {
    var nibName: String { get }
    func configure(view: UIView)
}

protocol ConfigurableSummaryItemView {
    associatedtype DataType: SummaryItemData
    func configure(data: DataType)
}

struct SummaryItemViewConfigurator<View: ConfigurableSummaryItemView, DataType>: SummaryItem where DataType == View.DataType, View: UIView {
    
    let data: DataType
    
    var nibName: String {
        return String(describing: View.self)
    }
    
    func configure(view: UIView) {
        (view as? View)?.configure(data: data)
    }
}
