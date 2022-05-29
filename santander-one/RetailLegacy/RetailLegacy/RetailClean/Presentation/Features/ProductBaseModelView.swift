import UIKit
import CoreDomain

protocol ProductBaseModelViewProtocol {
    func getHome() -> PrivateMenuProductHome?
    func getProduct() -> GenericProduct?
}

class ProductBaseModelView <P, T> : TableModelViewItem<T> where T: BaseViewCell {

    var product: P
    var home: PrivateMenuProductHome?
    var movements: Int? {
        return nil
    }
    var usesBottomPadding: Bool = true

    init(_ product: P, _ privateComponent: PresentationComponent) {
        self.product = product
        super.init(dependencies: privateComponent)
    }
    
    override func bind (viewCell: T) {
        if let viewCell = viewCell as? ItemProductBaseViewProtocol {
            if isLast() {
                viewCell.setBottomMode()
            } else {
                viewCell.setMiddleMode()
            }
        }
        viewCell.setNeedsDisplay()
        
        if let viewCell = viewCell as? ItemProductGenericProtocol {
            viewCell.setName(name: getName())
            viewCell.setSubName(subName: getSubName())
            viewCell.setQuantity(quantity: getQuantity())
            viewCell.setBackgroundColorCell(color: getBackgroundColor())
            viewCell.setUsesBottomPadding(value: usesBottomPadding)
        }
        configure(viewCell: viewCell)
    }
    
    override func configure(viewCell: T) {
        if let viewCell = viewCell as? ItemProductGenericViewCell {
            viewCell.setTransferCount(count: nil)
        }
    }
    
    func getName() -> String {
        return ""
    }
    
    func getSubName() -> String {
        return ""
    }
    
    func getQuantity() -> String {
        return ""
    }
    
    override var height: CGFloat? {
        return 76.0
    }
    
    func getBackgroundColor() -> UIColor {
        return .white
    }
}

extension ProductBaseModelView: ProductBaseModelViewProtocol {
    func getHome() -> PrivateMenuProductHome? {
        return home
    }
    
    func getProduct() -> GenericProduct? {
        return product as? GenericProduct
    }
}
