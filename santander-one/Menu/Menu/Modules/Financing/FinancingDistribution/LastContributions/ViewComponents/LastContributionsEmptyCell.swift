//
//  LastContributionsEmptyCell.swift
//  Menu
//
//  Created by Ignacio González Miró on 09/09/2020.
//

import UIKit
import CoreFoundationLib
import UI

class LastContributionsEmptyCell: UITableViewCell {

    @IBOutlet private weak var baseImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    public static var identifier: String {
        return String(describing: self)
    }
    
    public static var height: CGFloat {
        return CGFloat(211.0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

    func config(_ title: LocalizedStylableText) {
        self.titleLabel.configureText(withLocalizedString: title)
    }
}

private extension LastContributionsEmptyCell {
    func setupView() {
        self.setAppeareance()
        self.setIdentifiers()
    }
    
    func setAppeareance() {
        self.backgroundColor = .white
        self.baseImage.image = Assets.image(named: "imgLeaves")
        self.titleLabel.font = UIFont.santander(family: .headline, type: .regular, size: 20.0)
    }
    
    func setIdentifiers() {
        self.baseImage.accessibilityIdentifier = AccessibilityLastContributions.lcEmptyImage.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityLastContributions.lcEmptyTitle.rawValue
    }
}
