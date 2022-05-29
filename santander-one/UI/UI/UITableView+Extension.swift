//
//  UITableView+Extension.swift
//  UI
//
//  Created by Jose Carlos Estela Anguita on 07/01/2020.
//

import UIKit

public extension UITableView {
    
    func register<Cell: UITableViewCell>(_ cell: Cell.Type, bundle: Bundle?) {
        let identifier = String(describing: Cell.self)
        self.register(UINib(nibName: identifier, bundle: bundle), forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(_ cell: Cell.Type, indexPath: IndexPath) -> Cell {
        return self.dequeueReusableCell(withIdentifier: String(describing: Cell.self), for: indexPath) as? Cell ?? Cell()
    }
    
    func registerHeader<Cell: UITableViewHeaderFooterView>(header headerView: Cell.Type, bundle: Bundle?) {
        let identifier = String(describing: Cell.self)
        self.register(UINib(nibName: identifier, bundle: bundle), forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    /// Set table header view & add Auto layout.
    func setTableHeaderView(headerView: UIView) {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set first.
        self.tableHeaderView = headerView
        
        // Then setup AutoLayout.
        headerView.fullFit()
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
    
    /// Update header view's frame.
    func updateHeaderViewFrame() {
        guard let headerView = self.tableHeaderView else { return }
        
        // Update the size of the header based on its internal content.
        headerView.layoutIfNeeded()
        
        // ***Trigger table view to know that header should be updated.
        let header = self.tableHeaderView
        self.tableHeaderView = header
    }
    
    /// Update header view's frame when use AutoLayout
    func updateHeaderWithAutoLayout() {
        self.beginUpdates()
        if let headerView = self.tableHeaderView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            self.tableHeaderView = headerView
        }
        self.endUpdates()
    }
        
    func removeUnnecessaryHeaderTopPadding() {
#if swift(>=5.5)
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
#endif
    }
}
