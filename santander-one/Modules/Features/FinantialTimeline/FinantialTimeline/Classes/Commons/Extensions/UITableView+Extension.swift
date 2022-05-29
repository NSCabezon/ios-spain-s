//
//  UITableView+Extension.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 09/07/2019.
//

import UIKit

extension UITableView {
    
    func dequeueReusableCell<Cell: UITableViewCell>(type: Cell.Type) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: Cell.identifier) as? Cell else {
            fatalError("A cell with \(Cell.identifier) doesn't exist")
        }
        return cell
    }
    
    
    func reloadData(_ completion: @escaping () -> Void) {
        UIView.performWithoutAnimation {
            self.reloadData()
            DispatchQueue.main.async { completion() }
        }
    }
    
    func deselectAllItems(animated: Bool) {
        guard let selectedItems = indexPathsForSelectedRows else { return }
        for indexPath in selectedItems { deselectRow(at: indexPath, animated: animated) }
    }
}
