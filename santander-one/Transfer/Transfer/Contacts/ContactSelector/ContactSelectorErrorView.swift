//
//  ErrorContacts.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 06/02/2020.
//

import Foundation
import UIKit
import CoreFoundationLib
import UI

class ContactSelectorErrorView: XibView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        self.imageView.image = Assets.image(named: "imgLeaves")
        self.titleLabel.textColor = .lisboaGray
        let titleConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .headline, size: 20.0),
            alignment: .center,
            lineHeightMultiple: 0.9)
        self.titleLabel.configureText(withKey: "onePay_title_emptyFavorites",
                                      andConfiguration: titleConfig)
        self.subtitleLabel.textColor = .lisboaGray
        let subtitleConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .headline, size: 14.0),
            alignment: .center,
            lineHeightMultiple: 0.9)
        self.subtitleLabel.configureText(withKey: "onePay_label_emptyFavorites",
                                         andConfiguration: subtitleConfig)
        self.titleLabel.accessibilityIdentifier = AccessibilityTransferFavorites.onePayTitleEmptyFavorites.rawValue
        self.subtitleLabel.accessibilityIdentifier = AccessibilityTransferFavorites.onePayLabelEmptyFavorites.rawValue
        self.imageView.accessibilityIdentifier = "imgLeaves"
    }
}
