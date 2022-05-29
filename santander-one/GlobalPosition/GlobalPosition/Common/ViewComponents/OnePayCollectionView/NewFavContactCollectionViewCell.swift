//
//  NewFavContactCollectionViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 05/11/2019.
//

import UIKit
import CoreFoundationLib
import UI

final class NewFavContactCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var descLabel: UILabel?
    @IBOutlet weak private var textLabel: UILabel?
    @IBOutlet weak private var frameView: UIView?
    @IBOutlet weak private var circularView: UIView!
    @IBOutlet weak private var newContactImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func configureShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightSanGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 1
        configureDesc()
        configureText()
    }
}

private extension NewFavContactCollectionViewCell {
    func commonInit() {
        configureView()
        configureDesc()
        configureText()
        setAccessibilityId()
        setAccessibilityLabel()
        self.disableAccessibilityElements()
    }
    
    func configureView() {
        frameView?.layer.cornerRadius = 5.0
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        frameView?.layer.borderWidth = 1.0
        frameView?.backgroundColor = UIColor.white
        circularView.backgroundColor = UIColor.botonRedLight
        circularView.layer.cornerRadius = circularView.frame.size.width/2
        circularView.clipsToBounds = true
        newContactImageView.image = Assets.image(named: "icnNewContact")
    }
    
    func configureDesc() {
        descLabel?.clipsToBounds = true
        if let descLabel = descLabel {
            setParagraphStyle(to: descLabel, text: localized("pg_text_addFavoriteContacts"))
        }
    }
    
    func configureText() {
        textLabel?.text = localized("pg_label_newContacts")
        textLabel?.font = UIFont.santander(type: .bold, size: 16.0)
        textLabel?.textColor = UIColor.lisboaGray
    }
    
    func setParagraphStyle(to label: UILabel, text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = 0.75
        let builder = TextStylizer.Builder(fullText: text)
        label.attributedText = builder
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text).setStyle(UIFont.santander(family: .text, type: .regular, size: 11)))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text).setParagraphStyle(paragraphStyle))
            .build()
        label.textColor = UIColor.mediumSanGray
    }
    
    func setAccessibilityId() {
        self.frameView?.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.newContactPill.rawValue
        self.textLabel?.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.newContactPillTitle.rawValue
        self.descLabel?.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.newContactPillSubtitle.rawValue
        self.newContactImageView.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.newContactPillIcon.rawValue
    }
    
    func setAccessibilityLabel() {
        let textValue = self.textLabel?.text ?? ""
        let descValue = self.descLabel?.attributedText?.string ?? ""
        self.accessibilityValue = textValue + "\n" +
            descValue
        self.accessibilityTraits = .button
        self.isAccessibilityElement = true
    }
    
    func disableAccessibilityElements() {
        self.descLabel?.isAccessibilityElement = false
        self.textLabel?.isAccessibilityElement = false
    }
}
