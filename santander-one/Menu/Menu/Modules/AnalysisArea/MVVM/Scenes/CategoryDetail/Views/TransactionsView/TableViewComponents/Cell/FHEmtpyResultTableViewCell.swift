//
//  FHEmtpyResultTableViewCell.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 5/4/22.
//

import UIKit
import UIOneComponents

class FHEmtpyResultTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var containerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
        setAccesibilityIdentifiers()
    }
    
    func setCellInfo(message: String) {
        titleLabel.text = message
    }
}

private extension FHEmtpyResultTableViewCell {
    func setAppearance() {
        titleLabel.font = .typography(fontName: .oneH100Regular)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.text = ""
        containerImageView.setLeavesLoader()
        containerImageView.contentMode = .scaleAspectFill
    }
    
    func setAccesibilityIdentifiers() {
        self.accessibilityIdentifier = AnalysisAreaAccessibility.categoryDetailEmptyView
    }
}
