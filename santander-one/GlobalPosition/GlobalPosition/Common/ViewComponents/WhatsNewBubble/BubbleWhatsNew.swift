//
//  BubbleWhatsNew.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 26/06/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol BubbleWhatsNewDelegate: AnyObject {
    func didTapInWhatsNew()
}

public class BubbleWhatsNew: DesignableView {
    @IBOutlet private weak var clockImage: UIImageView!
    @IBOutlet private weak var arrowImage: UIImageView!
    @IBOutlet private weak var titleBubbleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var disclosureLabel: UILabel!
    @IBOutlet private weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageTrailingConstraint: NSLayoutConstraint!
    
    weak var delegate: BubbleWhatsNewDelegate?
    
    public override func commonInit() {
        super.commonInit()
        self.configureView()
        self.configureImage()
        self.circleBubble()
        self.isHidden = true
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.circleBubble()
    }
    
    func config(_ image: UIImage?, _ title: LocalizedStylableText?, _ description: LocalizedStylableText?, _ detail: LocalizedStylableText?) {
        guard let title = title, let description = description, let detail = detail else {
            self.clockImage.image = image
            self.hideLabels()
            self.arrowImage.isHidden = true
            self.superview?.layoutIfNeeded()
            return
        }
        self.clockImage.image = image
        self.titleBubbleLabel.configureText(withLocalizedString: title)
        self.descriptionLabel.configureText(withLocalizedString: description)
        self.disclosureLabel.configureText(withLocalizedString: detail)
        
        let arrowImage = Assets.image(named: "icnArrowRightGreen14pt")
        self.arrowImage.image = arrowImage
    }
    
    func updateImagePosition() {
        self.imageTopConstraint.constant = self.bounds.height / 2
        self.imageTrailingConstraint.constant = 40
        self.hideLabels()
    }
    
    @objc func didTapInBubble() {
        delegate?.didTapInWhatsNew()
    }
}

private extension BubbleWhatsNew {
    func circleBubble() {
        layer.cornerRadius = frame.width / 2
    }
    
    func configureView() {
        self.drawRoundedAndShadowedNew()
        self.setLabels()
        self.setIdentifiers()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapInBubble))
        self.addGestureRecognizer(gesture)
        self.backgroundColor = .iceBlue
        self.clipsToBounds = true
    }
    
    func configureImage() {
        self.clockImage.sizeThatFits(CGSize(width: 24, height: 24))
    }
    
    func setLabels() {
        self.titleBubbleLabel.textColor = .darkTorquoise
        self.descriptionLabel.textColor = .darkTorquoise
        self.disclosureLabel.textColor = .darkTorquoise
        self.titleBubbleLabel.numberOfLines = 2
        self.descriptionLabel.numberOfLines = 2
        self.titleBubbleLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .regular, size: 12.0)
        self.disclosureLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
    }
    
    func hideLabels() {
        self.titleBubbleLabel.isHidden = true
        self.descriptionLabel.isHidden = true
        self.disclosureLabel.isHidden = true
    }
    
    func setIdentifiers() {
        self.titleBubbleLabel.accessibilityIdentifier = AccessibilityWhatsNewBubble.titleBubble.rawValue
        self.descriptionLabel.accessibilityIdentifier = AccessibilityWhatsNewBubble.descriptionBubble.rawValue
        self.disclosureLabel.accessibilityIdentifier = AccessibilityWhatsNewBubble.detailBubble.rawValue
        self.clockImage.accessibilityIdentifier = AccessibilityWhatsNewBubble.bubbleArea.rawValue
        self.setAccessibility()
    }
    
    func setAccessibility() {
        self.accessibilityLabel = localized("voiceover_whatsNewSpeaker")
        self.accessibilityTraits = .button
    }
}
