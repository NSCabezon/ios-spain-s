//
//  SmartNoProductsCollectionViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 14/01/2020.
//

import UI
import CoreFoundationLib

class SmartNoProductsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        self.setAppearance()
        self.titleLabel.textColor = .white
        self.titleLabel.configureText(withKey: "pg_label_emptyView",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 20)))
        self.setAccessibilityIdentifiers()
    }
    
    private func setAppearance() {
        self.noResultView.layer.cornerRadius = 5
        self.noResultView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    private func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "pgSmart_noProducts_view"
        self.titleLabel.accessibilityIdentifier = "pgSmart_noProducts_title"
    }
}
