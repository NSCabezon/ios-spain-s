//
//  oneAppLink.swift
//  UIOneComponents
//
//  Created by Adrian Escriche on 31/8/21.
//

import UIKit
import UI
import CoreFoundationLib

// MARK: - OneAppLink Layout Configuration

private struct OneAppLinkLayoutConfiguration {
    let labelLineHeight: CGFloat
    let font: UIFont
    let textAlignment: NSTextAlignment
}

// MARK: - OneAppLink Layout Constants

private enum OneAppLinkLayoutConstants {
    // MARK: - Icons
    static let backIcon: String = "icnBack"
    static let gearIcon: String = "icnSettings"
    static let dropIcon: String = "icnArrowDownGreen"
    // MARK: - Priamry Colors
    static let primaryDefaultColor: UIColor = .oneBostonRed
    static let primaryPressedColor: UIColor = .oneRubyRed
    // MARK: - Secondary Colors
    static let secondaryDefaultColor: UIColor = .oneDarkTurquoise
    static let secondaryPressedColor: UIColor = .oneTurquoise
    // MARK: - Dissabled Color
    static let generalDissabledColor: UIColor = .oneLightSanGray
    // MARK: - Button Layouts
    static let oneAppLinkButtonLayoutConfig: OneAppLinkLayoutConfiguration = OneAppLinkLayoutConfiguration(
        labelLineHeight: OneSpacingType.oneSizeSpacing20.value,
        font: UIFont.typography(fontName: .oneB300Bold),
        textAlignment: .center)
}

// MARK: - OneAppLink Configuration

public extension OneAppLink {
    enum ButtonType {
        case primary, secondary
        
        fileprivate func textColor(_ isHighlighted: Bool) -> UIColor {
            switch self {
            case .primary:
                return isHighlighted ? OneAppLinkLayoutConstants.primaryPressedColor : OneAppLinkLayoutConstants.primaryDefaultColor
            case .secondary:
                return isHighlighted ? OneAppLinkLayoutConstants.secondaryPressedColor : OneAppLinkLayoutConstants.secondaryDefaultColor
            }
        }
    }
    
    struct ButtonContent {
        
        public let text: String
        public let textAlignment: NSTextAlignment?
        public let icons: ButtonIcons
        public enum ButtonIcons { case none, right, left, top }
        public var image: String?
        
        public init(text: String, icons: ButtonIcons, image: String? = nil, textAlignment: NSTextAlignment? = nil) {
            self.text = text
            self.textAlignment = textAlignment
            self.icons = icons
            self.image = image
        }
    }
}

// MARK: - OneAppLink

public final class OneAppLink: XibButton {
    
    @IBOutlet private weak var leftImageView: UIImageView?
    @IBOutlet private weak var textLabel: UILabel?
    @IBOutlet private weak var rightImageView: UIImageView?
    @IBOutlet private weak var topImageView: UIImageView?
    @IBOutlet private weak var widthConstraints: NSLayoutConstraint?
    
    public var oneAppLinkType: ButtonType = .primary {
        didSet {
            self.setTypeAppearance()
        }
    }
    
    public var buttonStyle: ButtonContent = ButtonContent(text: "Configura tu boton bien fresco", icons: .right){
        didSet{
            self.setLabels()
            self.setAppearance()
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                setHighlightAppearance()
            }
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled {
                setEnabledApperance()
            }
        }
    }
    
    // MARK: - Init
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
        self.setAccessibilityIdentifiers()
    }
    
    public func configureView() {
        self.setOneAppLinkImages()
        self.leftImageView?.isHidden = true
        self.rightImageView?.isHidden = true
        
        // Base appearance
        self.configureButton(type: self.oneAppLinkType, style: self.buttonStyle)
        self.subviews.forEach { $0.isUserInteractionEnabled = false }
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    private func setOneAppLinkImages(){
        if self.oneAppLinkType == .primary {
            self.leftImageView?.image = Assets.image(named: OneAppLinkLayoutConstants.backIcon)?.withRenderingMode(.alwaysTemplate)
            self.leftImageView?.transform = CGAffineTransform(rotationAngle: .pi)
            self.rightImageView?.image = Assets.image(named: OneAppLinkLayoutConstants.backIcon)?.withRenderingMode(.alwaysTemplate)
            self.setTopImage(buttonStyle.image)
        } else {
            self.leftImageView?.image = Assets.image(named: OneAppLinkLayoutConstants.gearIcon)?.withRenderingMode(.alwaysTemplate)
            self.rightImageView?.image = Assets.image(named: OneAppLinkLayoutConstants.dropIcon)?.withRenderingMode(.alwaysTemplate)
            self.setTopImage(buttonStyle.image)
        }
    }
    
    public func configureButton(type: ButtonType, style: ButtonContent) {
        self.oneAppLinkType = type
        self.buttonStyle = style
    }
    
    public func setAlignment(_ alignment: NSTextAlignment) {
        self.textLabel?.textAlignment = alignment
    }
    
    public func setTopImage(_ imageName: String?) {
        guard let imageName = imageName else {
            return
        }
        self.topImageView?.image = Assets.image(named: imageName)?.withRenderingMode(.alwaysTemplate)
    }
}

private extension OneAppLink {
    
    func setTypeAppearance(){
        self.setColorsAppearance(linkColor: self.oneAppLinkType.textColor(self.isHighlighted))
    }
    
    func setLabels() {
        self.textLabel?.text = self.buttonStyle.text
    }
    
    func setHighlightAppearance() {
        setTypeAppearance()
    }
    
    func setAppearance() {
        self.textLabel?.font = OneAppLinkLayoutConstants.oneAppLinkButtonLayoutConfig.font
        let alignment = buttonStyle.textAlignment ?? OneAppLinkLayoutConstants.oneAppLinkButtonLayoutConfig.textAlignment
        self.textLabel?.textAlignment = alignment
        self.setOneAppLinkImages()
        self.textLabel?.sizeToFit()
        switch self.buttonStyle.icons {
        case .right:
            self.rightImageView?.isHidden = false
            self.leftImageView?.isHidden = true
            self.topImageView?.isHidden = true
        case .left:
            self.rightImageView?.isHidden = true
            self.leftImageView?.isHidden = false
            self.topImageView?.isHidden = true
        case .top:
            self.rightImageView?.isHidden = true
            self.leftImageView?.isHidden = true
            self.topImageView?.isHidden = false
            self.textLabel?.font = UIFont.typography(fontName: .oneB100Bold)
        case .none:
            self.rightImageView?.isHidden = true
            self.leftImageView?.isHidden = true
            self.topImageView?.isHidden = true
        }
    }
    
    func setEnabledApperance() {
        if isEnabled {
            setTypeAppearance()
        } else {
            setColorsAppearance(linkColor: OneAppLinkLayoutConstants.generalDissabledColor)
        }
    }
    
    func setColorsAppearance(linkColor: UIColor){
        self.leftImageView?.tintColor = linkColor
        self.rightImageView?.tintColor = linkColor
        self.topImageView?.tintColor = linkColor
        self.textLabel?.textColor = linkColor
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.leftImageView?.accessibilityIdentifier = AccessibilityOneComponents.oneAppLinkLeftImage + (suffix ?? "")
        self.rightImageView?.accessibilityIdentifier = AccessibilityOneComponents.oneAppLinkRightImage + (suffix ?? "")
        self.topImageView?.accessibilityIdentifier = AccessibilityOneComponents.oneAppLinkTopImage + (suffix ?? "")
        self.textLabel?.accessibilityIdentifier = AccessibilityOneComponents.oneAppLinkLabel + (suffix ?? "")
        self.accessibilityIdentifier = AccessibilityOneComponents.oneAppLink + (suffix ?? "")
    }
}

