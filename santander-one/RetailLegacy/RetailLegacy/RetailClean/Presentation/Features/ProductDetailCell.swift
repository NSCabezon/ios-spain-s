import UIKit

protocol ProductDetailCell {
    var isFirst: Bool { get }
    var isCopiable: Bool { get }
    var isEditable: Bool { get }
    var editDelegate: ProductDetailInfoDataSourceDelegate? { get set }

    var shortSeparator: UIView! { get }
    var copyButton: UIButton! { get }
    var editButton: UIButton! { get }

    func showSeparator()
    func showCopy()
    func showEdit()
}

extension ProductDetailCell {
    func showSeparator() {
        shortSeparator.isHidden = isFirst
    }
    
    func showCopy() {
        copyButton.isHidden = !isCopiable
    }
    
    func showEdit() {
        editButton.isHidden = !isEditable
    }
    
}
