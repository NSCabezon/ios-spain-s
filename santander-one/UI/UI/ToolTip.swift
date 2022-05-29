//
//  ToolTip.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 14/01/2020.
//

import CoreFoundationLib
import UIKit

final public class ToolTipButton: UIButton {
    private var action: ((_ sender: UIView) -> Void)?

    public func setup(size: CGFloat = 44,
                      imageEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 29, left: 29, bottom: 29, right: 29),
                      imageContentMode: ContentMode = .scaleAspectFill,
                      withAction action: @escaping (_ sender: UIView) -> Void) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: size).isActive = true
        self.heightAnchor.constraint(equalToConstant: size).isActive = true
        self.setImage(Assets.image(named: "icnInfoRedLight"), for: .normal)
        self.isAccessibilityElement = true
        self.imageView?.contentMode = imageContentMode
        self.imageEdgeInsets = imageEdgeInsets
        self.add(action: action)
    }

    public func setupBg(size: CGFloat = 50, spacing: CGFloat = 3,
                        type: NavigationBarBuilder.ToolTipType,
                        maxWidth: CGFloat? = nil,
                        action: @escaping (_ sender: UIView) -> Void) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imageView?.widthAnchor.constraint(equalToConstant: size).isActive = true
        self.imageView?.heightAnchor.constraint(lessThanOrEqualToConstant: size).isActive = true
        var image = Assets.image(named: "icnInfoRedLight")
        self.isAccessibilityElement = true
        if type == .white {
            image = image?.withRenderingMode(.alwaysTemplate)
            imageView?.tintColor = .white
        }
        self.setImage(image, for: .normal)
        self.imageView?.contentMode = .scaleAspectFill
        self.imageView?.accessibilityIdentifier = AccessibilityNavigation.tooltipViewImageKey
        self.imageView?.image?.accessibilityIdentifier = AccessibilityNavigation.tooltipViewImageKey + "Image"
        let isZoomEnabled = UIScreen.main.bounds.size.height == Screen.iphone5Height && UIScreen.main.nativeScale > UIScreen.main.scale
        let fontSize: CGFloat = Screen.isIphone4or5 || isZoomEnabled ? 16.5 : 18.0
        self.titleLabel?.font = UIFont.santander(family: .headline, type: .bold, size: fontSize)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.lineBreakMode = .byTruncatingTail
        self.titleLabel?.minimumScaleFactor = 0.1
        guard let imageWidth = self.imageView?.frame.width, let labelWidth = self.titleLabel?.frame.width else { return }
        let max = maxWidth ?? CGFloat.infinity
        let maxAllowedLabelWidth = (labelWidth + size + spacing) > max ?
            max - size - spacing :
            labelWidth
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: maxAllowedLabelWidth + spacing, bottom: 0, right: -maxAllowedLabelWidth - spacing)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth - spacing, bottom: 0, right: imageWidth + spacing)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        let btnWidth = self.imageEdgeInsets.left + self.titleEdgeInsets.right
        self.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
        self.heightAnchor.constraint(equalToConstant: size).isActive = true
        self.contentHorizontalAlignment = .left
        self.contentVerticalAlignment = .center
        self.add(action: action)
    }
    
    public func getInfoImageView() -> UIImageView? {
        return self.imageView
    }
    
    func add(action: @escaping (_ sender: UIView) -> Void) {
        self.action = action
        self.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
    }
    
    @objc func buttonSelected(sender: UIView) {
        self.action?(sender)
    }
}

extension ToolTipButton: ToolTipButtonDeRigueur {
    public var tooltip: UIView? {
        return self.imageView
    }
    
    public var xCorrectionPadding: CGFloat {
        return 7
    }
}
