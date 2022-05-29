import UIKit

protocol DraggableTableViewDataSourceDelegate: class {
    func moveInSection(section: TableModelViewSection)
    func didMoveItem(item: TableModelViewProtocol)
}

class DraggableTableViewDataSource: TableDataSource {
    weak var movementsDelegate: DraggableTableViewDataSourceDelegate?
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == sourceIndexPath.section {
            return proposedDestinationIndexPath
        }
        let limitRow = proposedDestinationIndexPath.section < sourceIndexPath.section ? 0 : tableView.numberOfRows(inSection: sourceIndexPath.section) - 1
        return IndexPath(row: limitRow, section: sourceIndexPath.section)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        movementsDelegate?.moveInSection(section: sections[sourceIndexPath.section])
        sections[sourceIndexPath.section].moveItemAt(position: sourceIndexPath.row, to: destinationIndexPath.row)
        
        guard let item =  sections[destinationIndexPath.section].get(destinationIndexPath.row) else {
            return
        }

        movementsDelegate?.didMoveItem(item: item)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for view in cell.subviews {
            if view.description.range(of: "UITableViewCellReorderControl") != nil {
                let resizedGripView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.maxX, height: view.frame.maxY))
                resizedGripView.addSubview(view)
                for v in view.subviews {
                    if let v = v as? UIImageView {
                        v.image = nil
                    }
                }
                cell.addSubview(resizedGripView)
                let transform = CGAffineTransform(translationX: view.frame.size.width - cell.frame.size.width, y: 1)
                resizedGripView.transform = transform
            }
        }
    }
}
