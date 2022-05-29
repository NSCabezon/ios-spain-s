//
//  NewContactCollectionViewCell.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 05/02/2020.
//

import Foundation
import CoreFoundationLib
import UI

final class NewContactCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak private var addContactLabel: UILabel!
    @IBOutlet weak private var newContactLabel: UILabel!
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var circleView: UIView!
    @IBOutlet weak private var newContactsImageView: UIImageView!
    private var groupedAccessibilityElements: [Any]?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        self.setupAccessibilityId()
    }
}

private extension NewContactCollectionViewCell {
    func setupView() {
        self.setupShadow()
        self.setupContactView()
    }
    
    func setupShadow() {
        self.containerView.backgroundColor = UIColor.white
        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.containerView.layer.shadowOpacity = 0.59
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.containerView.layer.shadowRadius = 0.0
        self.containerView.layer.masksToBounds = false
        self.containerView.clipsToBounds = false
        self.containerView.drawBorder(cornerRadius: 5, color: UIColor.lightSkyBlue, width: 1)
    }
    
    func setupContactView() {
        self.circleView.backgroundColor = UIColor.botonRedLight
        self.circleView.layer.cornerRadius = circleView.frame.size.width/2
        self.circleView.clipsToBounds = true
        self.newContactsImageView.image = Assets.image(named: "icnNewContact")
        self.newContactLabel?.text = localized("pg_label_newContacts")
        self.newContactLabel?.font = UIFont.santander(family: .text, type: .bold, size: 18.0)
        self.newContactLabel?.textColor = UIColor.lisboaGray
        setParagraphStyle(to: addContactLabel, text: localized("pg_text_addFavoriteContacts"))
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
    
    func setupAccessibilityId() {
        newContactLabel.accessibilityTraits = .button
        addContactLabel.accessibilityElementsHidden = true
        self.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeBtnFavoriteNewContact
    }
}

extension NewContactCollectionViewCell {
    public override var accessibilityElements: [Any]? {
        get {
            if let groupedAccessibilityElements = groupedAccessibilityElements {
                return groupedAccessibilityElements
            }
            let elements = self.groupElements([addContactLabel,
                                               newContactLabel])
            groupedAccessibilityElements = elements
            return groupedAccessibilityElements
        }
        set {
            groupedAccessibilityElements = newValue
        }
    }
}
