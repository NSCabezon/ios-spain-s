import UIKit

extension UITableView {
    func registerCells(nibsArray: [AnyClass]) {
        for eachClass in nibsArray {
            let classString = String(describing: eachClass)
            let nib = UINib(nibName: classString, bundle: nil)
            register(nib, forCellReuseIdentifier: classString)
        }
    }
	
    func registerCells(classesArray: [AnyClass]) {
        for eachClass in classesArray {
            let classString = String(describing: eachClass)
            register(eachClass, forCellReuseIdentifier: classString)
        }
    }
}
