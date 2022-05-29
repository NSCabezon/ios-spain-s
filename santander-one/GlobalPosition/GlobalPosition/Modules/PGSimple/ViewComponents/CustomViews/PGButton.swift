//
//  PGButton.swift
//  toTest
//
//  Created by alvola on 08/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import UI
import CoreFoundationLib

final class PGButton: DesignableView {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var img: UIImageView?
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var highlightedContainer: UIView!
    @IBOutlet weak var highlightedLabel: UILabel!
    @IBOutlet private weak var offerContainer: UIView!
    @IBOutlet private weak var offerImageView: UIImageView!

    override func commonInit() {
        super.commonInit()
        configureLabel()
        configureView()
        configureExtraLabel()
    }
    
    func setTitle(_ title: String, imgName: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = -0.5
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = 0.75
        let builder = TextStylizer.Builder(fullText: title)
        self.label?.attributedText = builder
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: title).setStyle(UIFont.santander(family: .text, type: .regular, size: 13.0)))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: title).setParagraphStyle(paragraphStyle))
            .build()
        offerContainer.isHidden = true
        container.isHidden = false
        let image = Assets.image(named: imgName)?.withRenderingMode(.alwaysTemplate)
        img?.image = image
        img?.tintColor = UIColor.botonRedLight
    }
    
    public func setImageUrl(_ url: String) {
        offerContainer.isHidden = false
        container.isHidden = true
        addShadow(for: offerContainer)
        offerImageView.loadImage(urlString: url)
    }
    
    public func setExtraLabelContent(_ content: HighlightedInfo) {
        guard
            !content.text.isEmpty,
            let textColor = content.style?.textColor,
            let borderColor = content.style?.borderColor,
            let backgroundColor = content.style?.backgroundColor
            else {
                highlightedContainer.isHidden = true
                highlightedLabel.text = ""
                return
        }
        highlightedContainer.isHidden = false
        highlightedLabel.text = content.text.uppercased()
        highlightedLabel.textColor = textColor
        highlightedContainer.backgroundColor = backgroundColor
        highlightedContainer.layer.borderColor = borderColor.cgColor
        highlightedContainer.layer.borderWidth = 1
        highlightedContainer.layer.cornerRadius = 2
    }
    
    private func configureLabel() {
        label?.textColor = UIColor.lisboaGray
        label?.adjustsFontSizeToFitWidth = true
        label?.sizeToFit()
    }
    
    private func configureView() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 5
        self.addShadow(for: container)
    }
    
    private func configureExtraLabel() {
        highlightedContainer.layer.cornerRadius = 2
        highlightedLabel.font = UIFont.santander(family: .text, type: .bold, size: 10)
        highlightedContainer.isHidden = true
    }
    
    private func addShadow(for contentView: UIView) {
           contentView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
           contentView.layer.shadowOpacity = 0.7
           contentView.layer.shadowColor = UIColor.mediumSkyGray.cgColor
           contentView.layer.shadowRadius = 2
           contentView.layer.masksToBounds = false
           contentView.clipsToBounds = false
           contentView.drawBorder(cornerRadius: 5, color: UIColor.mediumSkyGray, width: 1)
       }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = UIColor.bg
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        backgroundColor = UIColor.white
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        backgroundColor = UIColor.white
    }
    
    func applyDisabledStyle() {
        backgroundColor = UIColor.silverDark
        img?.tintColor = UIColor.coolGray
        label?.textColor = UIColor.coolGray
    }
    
    func applyEnabledStyle() {
        backgroundColor = UIColor.white
        img?.tintColor = UIColor.botonRedLight
        label?.textColor = UIColor.lisboaGray
    }
}

private extension HighlightedInfo.HighlightedInfoStyle {
    var textColor: UIColor {
        switch self {
        case .darkTurquoise:
            return .white
        case .skyGray:
            return .mediumSanGray
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .darkTurquoise:
            return .darkTorquoise
        case .skyGray:
            return .skyGray
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .darkTurquoise:
            return .clear
        case .skyGray:
            return .mediumSkyGray
        }
    }
}
