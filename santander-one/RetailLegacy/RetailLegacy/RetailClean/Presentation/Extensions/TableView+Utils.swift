import UIKit

extension UITableView {
    
    func registerCells(_ cellIdentifiers: [String]) {
        for identifier in cellIdentifiers {
            register(UINib(nibName: identifier, bundle: .module), forCellReuseIdentifier: identifier)
        }
    }
    
    func registerHeaderFooters(_ headerIdentifiers: [String]) {
        for identifier in headerIdentifiers {
            register(UINib(nibName: identifier, bundle: .module), forHeaderFooterViewReuseIdentifier: identifier)
        }
    }
    
    func reloadData(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0,
            animations: {
                self.reloadData()
            },
            completion: { finished in
                if finished {
                    completion()
                }
            }
        
        )
    }
    
    func canScroll() -> Bool {
        return contentSize.height >= frame.height
    }
}
