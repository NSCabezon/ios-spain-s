import CoreFoundationLib

protocol UnreadCrossSellingViewProtocol: AnyObject {
    var crossSellingSelected: CrossSellingRepresentable? { get set }
    var index: Int { get }
    var isCrossSellingEnabled: Bool { get }
}
