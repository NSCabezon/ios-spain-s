import Foundation

public protocol EmptyPurchaseCloseDelegate: AnyObject {
    func didTapInDismiss(_ completion: (() -> Void)?)
}
