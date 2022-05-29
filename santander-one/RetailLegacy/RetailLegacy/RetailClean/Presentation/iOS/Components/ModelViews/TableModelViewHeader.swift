import UIKit

protocol TableModelViewHeaderDelegate: class {
    func onTableModelViewHeaderSelected(section: TableModelViewSection)
}

class TableModelViewHeader<ViewHeader>: NSObject, TableModelViewHeaderProtocol, BaseViewHeaderDelegate where ViewHeader: BaseViewHeader {
    
    weak var section: TableModelViewSection?
    var collapsed: Bool = false
    weak var mDelegate: TableModelViewHeaderDelegate?
    
    func bind<ViewHeaderProtocol>(viewHeader: ViewHeaderProtocol) where ViewHeaderProtocol: BaseViewHeader {
        if let viewHeader = viewHeader as? ViewHeader {
            bind(viewHeader: viewHeader)
        }
    }
    
    func bind(viewHeader: ViewHeader) {
        viewHeader.setBaseViewHeaderDelegate(mDelegate: self)
        viewHeader.setCollapsed(collapsed: collapsed)
        viewHeader.setNeedsDisplay()
    }
    
    func configure(viewHeader: ViewHeader) {
    }
    
    func configure<ViewHeaderProtocol>(viewHeader: ViewHeaderProtocol) where ViewHeaderProtocol: BaseViewHeader {
        if let viewHeader = viewHeader as? ViewHeader {
            configure(viewHeader: viewHeader)
        }
    }

    var height: CGFloat {
        return UITableView.automaticDimension
    }

    var identifier: String {
        let parts = (String(describing: type(of: ViewHeader.self))).split(separator: ".")
        return String(parts[0])
    }
    
    func setCollapsed(collapsed: Bool) {
        self.collapsed = collapsed
    }
    
    func setTableModelViewHeaderDelegate(mDelegate: TableModelViewHeaderDelegate) {
        self.mDelegate = mDelegate
    }
    
    func didTapHeader() {
        
    }
}
