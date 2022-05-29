import UIKit

protocol TableModelViewHeaderProtocol {
    var identifier: String {get}
    var height: CGFloat {get}
    func bind <ViewHeaderProtocol> (viewHeader: ViewHeaderProtocol)  where ViewHeaderProtocol: BaseViewHeader
    func configure<ViewHeaderProtocol>(viewHeader: ViewHeaderProtocol) where ViewHeaderProtocol: BaseViewHeader
    func setCollapsed(collapsed: Bool)
    func setTableModelViewHeaderDelegate(mDelegate: TableModelViewHeaderDelegate)
}
