//
//  SubMenuSectionTableViewHeader.swift
//  PrivateMenu
//
//  Created by Daniel Gómez Barroso on 22/3/22.
//

import UI
import CoreGraphics
import UIKit

final class SubMenuSectionTableViewHeader: UITableViewHeaderFooterView {
    private struct Constants {
        static let labelNumberOfLines: Int = 1
        static let headerHeight: CGFloat = 22
        static let labelLeftAnchorConstraint: CGFloat = 24
        static let labelVerticalSpacing: CGFloat = 11
        static let backgroundAlphaValue: CGFloat = 0.9
        static let labelFontSize: CGFloat = 13
        static let labelLineHeightMultiple: CGFloat = 1
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = Constants.labelNumberOfLines
        label.textColor = .grafite
        label.textAlignment = .left
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
}

private extension SubMenuSectionTableViewHeader {
    func commonInit() {
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: Constants.headerHeight),
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Constants.labelLeftAnchorConstraint),
            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Constants.labelVerticalSpacing)
            ])
        setupView()
    }
    
    func setupView() {
        if #available(iOS 14.0, *) {
            var backgroundConfig = UIBackgroundConfiguration.clear()
            backgroundConfig.backgroundColor = UIColor.white.withAlphaComponent(Constants.backgroundAlphaValue)
            backgroundConfiguration = backgroundConfig
        } else {
            self.layer.backgroundColor = UIColor.white.withAlphaComponent(Constants.backgroundAlphaValue).cgColor
        }
    }
}

extension SubMenuSectionTableViewHeader: SectionTypeConfigurableProtocol {
    func configureLabel(with titleKey: String) {
        let font = UIFont.santander(family: .text ,
                                    type: .bold,
                                    size: Constants.labelFontSize)
        let configuration = LocalizedStylableTextConfiguration(font: font,
                                                               alignment: .left,
                                                               lineHeightMultiple: Constants.labelLineHeightMultiple, lineBreakMode: nil)
        label.configureText(withKey: titleKey, andConfiguration: configuration)
        label.accessibilityIdentifier = titleKey
    }
}
