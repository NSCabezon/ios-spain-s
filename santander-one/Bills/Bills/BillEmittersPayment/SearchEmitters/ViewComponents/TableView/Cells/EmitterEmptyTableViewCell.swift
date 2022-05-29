//
//  EmitterEmptyTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import UIKit
import UI
import CoreFoundationLib

final class EmitterEmptyTableViewCell: UITableViewCell {
    static let identifier = "EmitterEmptyTableViewCell"
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.isUserInteractionEnabled = false
        self.emptyImageView.image = Assets.image(named: "imgLeaves")
    }
    
    func setSearchTerm(term: String?) {
        guard let searchTerm = term, !searchTerm.isEmpty else {
            self.hideEmptyView()
            return
        }
        self.emptyTitleLabel.configureText(withLocalizedString: localized("globalSearch_title_empty", [StringPlaceholder(.value, searchTerm)]))
        self.showEmptyView()
    }
    
    func hideEmptyView() {
        self.emptyTitleLabel.isHidden = true
        self.emptyImageView.isHidden = true
    }
    
    func showEmptyView() {
        self.emptyTitleLabel.isHidden = false
        self.emptyImageView.isHidden = false
    }
}
