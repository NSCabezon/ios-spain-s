//
//  NoResultsTableViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 10/01/2020.
//

import UIKit
import UI

final class NoResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var noResultView: NoProductsView?

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        selectionStyle = .none
        noResultView?.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.skyGray
        setAccessibilityIdentifier()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 211.0)
    }
    
    private func setAccessibilityIdentifier() {
        self.accessibilityIdentifier = "pg_view_emptyView"
        noResultView?.accessibilityIdentifier = "pg_view_emptyView"
    }
}
