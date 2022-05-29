//
//  SavingCollectionViewCell.swift
//  Menu
//
//  Created by David Gálvez Alonso on 20/03/2020.
//

import UIKit
import CoreFoundationLib
import UI

class SavingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var frameView: UIView!
    @IBOutlet weak private var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setImageCell(_ imageUrl: String?) {
        if let imageUrl = imageUrl {
            self.iconImageView.loadImage(urlString: imageUrl)
        }
    }
    
    func setTextCell(_ text: String) {
        textLabel?.configureText(withLocalizedString: localized(text))
    }
    
    func setAccessibilityIdentifier(_ accessibilityIdentifier: String) {
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

// MARK: - Private methods

private extension SavingCollectionViewCell {
    
    func commonInit() {
        configureText()
        configureView()
    }
    
    func configureView() {
        frameView?.layer.cornerRadius = 5.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        frameView?.layer.borderWidth = 1.0
        frameView?.backgroundColor = UIColor.white
    }
    
    func configureText() {
        textLabel?.font = UIFont.santander(family: .text, type: .regular, size: 20.0)
        textLabel?.textColor = UIColor.lisboaGray
    }
}
