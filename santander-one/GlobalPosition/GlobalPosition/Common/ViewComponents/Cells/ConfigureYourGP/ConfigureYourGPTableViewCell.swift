//
//  ConfigureYourGPTableViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 31/03/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class ConfigureYourGPTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    // MARK: - privateMethods
    
    private func commonInit() {
        configureView()
        configureLabels()
        iconImage?.image = Assets.image(named: "icnConfigPg")
        setAccessibilityIdentifiers()
    }
    
    private func configureView() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
    }
    
    private func configureLabels() {
        titleLabel?.font = UIFont.santander(family: .text, size: 14.0)
        titleLabel?.textColor = UIColor.darkTorquoise
        titleLabel?.text = localized("pg_link_setPg")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 58.0)
    }
    
    private func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityGlobalPosition.pgConfigureView
        titleLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgConfigureTitleLabel
        iconImage.accessibilityIdentifier = AccessibilityGlobalPosition.pgConfigureIcn
    }
}
