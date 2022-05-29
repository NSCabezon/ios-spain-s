//
//  UICollectionView+Extension.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 05/02/2020.
//

import UIKit

extension UICollectionView {
    
    public func dequeue<CellType: UICollectionViewCell>(type: CellType.Type, at indexPath: IndexPath) -> CellType {
        return self.dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as? CellType ?? CellType()
    }
    
    public func register<CellType: UICollectionViewCell>(type: CellType.Type, bundle: Bundle?) {
        let cellIdentifier = String(describing: type)
        self.register(UINib(nibName: cellIdentifier, bundle: bundle), forCellWithReuseIdentifier: cellIdentifier)
    }
}
