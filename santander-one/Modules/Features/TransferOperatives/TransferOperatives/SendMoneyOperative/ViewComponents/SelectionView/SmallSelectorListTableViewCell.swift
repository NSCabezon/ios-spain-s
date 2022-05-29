//
//  SmallSelectorListTableViewCell.swift
//  TransferOperatives
//
//  Created by David Gálvez Alonso on 11/1/22.
//

import UIOneComponents
import CoreFoundationLib

final class SmallSelectorListTableViewCell: UITableViewCell {

    @IBOutlet private weak var smallSelectorView: OneSmallSelectorListView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .none
        self.selectionStyle = .none
        self.contentView.isAccessibilityElement = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.smallSelectorView.prepareForReuse()
    }
    
    func configure(_ viewModel: OneSmallSelectorListViewModel, index: Int, delegate: OneSmallSelectorListViewDelegate?) {
        self.smallSelectorView.setViewModel(viewModel, index: index)
        self.smallSelectorView.delegate = delegate
    }
}

extension SmallSelectorListTableViewCell: AccessibilityCapable {}
