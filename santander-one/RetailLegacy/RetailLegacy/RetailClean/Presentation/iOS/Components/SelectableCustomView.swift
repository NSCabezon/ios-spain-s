import UIKit.UIView

protocol SelectableCustomView: UIView {
    func onSelection(isSelected: Bool)
}
