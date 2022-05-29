//
//  AutoSizeTableView.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 01/09/2020.
//

import UIKit

public class AutoSizeTableView: UITableView {
    private var maxHeight: CGFloat = Screen.resolution.height
    
    override public func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override public var intrinsicContentSize: CGSize {
        setNeedsLayout()
        layoutIfNeeded()
        let tableHeight = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: tableHeight)
    }
}
