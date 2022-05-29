import UIKit

extension UICollectionView {
    func registerCells(_ cellIdentifiers: [String]) {
        for identifier in cellIdentifiers {
            register(UINib(nibName: identifier, bundle: .module), forCellWithReuseIdentifier: identifier)
        }
    }
    
    func registerHeaderFooters(_ headerIdentifiers: [String]) {
        for identifier in headerIdentifiers {
            register(UINib(nibName: identifier, bundle: .module), forCellWithReuseIdentifier: identifier)
        }
    }
}
