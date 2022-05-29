import UIKit
import CoreFoundationLib

protocol TableModelViewProtocol {
    var identifier: String {get}
    var position: (Int, Int) {get set}
    func bind <ViewCellProtocol> (viewCell: ViewCellProtocol)  where ViewCellProtocol: BaseViewCell
    func configure <ViewCellProtocol> (viewCell: ViewCellProtocol)  where ViewCellProtocol: BaseViewCell
    var height: CGFloat? {get}
    var accessibilityIdentifier: String? { get set }
}

class TableModelViewItem <ViewCell> : NSObject, AccessibilityProtocol, TableModelViewProtocol where ViewCell: BaseViewCell {

    var dependencies: PresentationComponent
    weak var section: TableModelViewSection?

    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }

    var height: CGFloat? {
        return nil
    }

    var identifier: String {
        let parts = (String(describing: type(of: ViewCell.self))).split(separator: ".")        
        return String(parts[0])
    }
    
    var position: (Int, Int) = (-1, -1)
	
	var accessibilityIdentifier: String?

    func bind<ViewCellProtocol>(viewCell: ViewCellProtocol) {
        if let viewCell = viewCell as? ViewCell {
            bind(viewCell: viewCell)
        }
    }
    
    func bind(viewCell: ViewCell) {
        fatalError()
    }
    
    func configure(viewCell: ViewCell) {
    }
    
    func configure<ViewCellProtocol>(viewCell: ViewCellProtocol) {
        if let viewCell = viewCell as? ViewCell {
            configure(viewCell: viewCell)
        }
    }
    
    func isFirst() -> Bool {
        return position.0 == 0
    }
    
    func isLast() -> Bool {
        return position.0 == position.1-1
    }
    
    func isEvenPosition() -> Bool {
        return position.0 % 2 == 0
    }

}
