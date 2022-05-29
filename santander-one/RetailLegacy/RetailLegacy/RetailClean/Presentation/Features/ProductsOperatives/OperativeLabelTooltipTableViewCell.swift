//
//  OperativeLabelTooltipTableViewCell.swift
//  RetailClean
//
//  Created by alvola on 16/11/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit
import UI

final class OperativeLabelTooltipTableViewCell: BaseViewCell {
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var tooltipIcon: UIImageView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!

    private enum Constants {
        static let infoIconImage = "icnInfoCard"
    }

    var title: LocalizedStylableText? {
        didSet {
            guard let title = title else { return }
            typeLabel.set(localizedStylableText: title)
        }
    }
    
    var titleHtml: String? {
        didSet {
            guard let html = titleHtml else { return }
            let data = Data(html.utf8)
            if let attributedString = try? NSAttributedString(data: data,
                                                              options: [.documentType: NSAttributedString.DocumentType.html,
                                                                        .characterEncoding: String.Encoding.utf8.rawValue],
                                                              documentAttributes: nil) {
                typeLabel.attributedText = attributedString
            }
        }
    }
    
    var style: LabelStylist? {
        didSet {
            guard let style = style else { return }
            (typeLabel as UILabel).applyStyle(style)
        }
    }
    
    var tooltipText: String?
    
    func applyInsets(insets: Insets?) {
        if let insets = insets {
            bottomConstraint.constant = CGFloat(insets.bottom)
            leftConstraint.constant = CGFloat(insets.left)
            rightConstraint.constant = CGFloat(insets.right)
            topConstraint.constant = CGFloat(insets.top)
            layoutSubviews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        typeLabel.sizeToFit()
        typeLabel.numberOfLines = 0
        backgroundColor = .uiBackground
        selectionStyle = .none
        tooltipIcon.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(didPressTooltip)))
        if let infoIcon = Assets.image(named: Constants.infoIconImage) {
            tooltipIcon.image = infoIcon
        }
    }
    
    @objc private func didPressTooltip() {
        guard let tooltipText = tooltipText else { return }
        var configuration = BubbleLabelConfiguration.defaultConfiguration()
        configuration.fixedWidth = self.frame.width - (rightConstraint.constant + leftConstraint.constant)
        BubbleLabelView.startWith(associated: tooltipIcon,
                                  text: tooltipText,
                                  position: .bottom,
                                  configuration: configuration)
    }
    
    func setAccessibilityIdentifiers(identifier: String) {
        typeLabel.accessibilityIdentifier = identifier + "_title"
        tooltipIcon.accessibilityIdentifier = identifier + "_image"
    }
}
