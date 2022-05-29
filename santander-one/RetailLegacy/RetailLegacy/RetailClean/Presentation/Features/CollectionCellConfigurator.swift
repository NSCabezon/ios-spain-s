//

import UIKit

protocol CarouselItem {
    var identifier: String { get }
    func configure(cell: UICollectionViewCell)
}

struct VoidCarouselItem {
}

extension VoidCarouselItem: CarouselItem {
    var identifier: String {
        return ""
    }
    func configure(cell: UICollectionViewCell) {}
}

struct CollectionCellConfigurator<Cell: ConfigurableCell, DataType>: CarouselItem where DataType == Cell.DataType, Cell: UICollectionViewCell {
    
    let data: DataType
    
    func configure(cell: UICollectionViewCell) {
        (cell as? Cell)?.configure(data: data)
    }
    
    var identifier: String {
        return String(describing: Cell.self)
    }
}
