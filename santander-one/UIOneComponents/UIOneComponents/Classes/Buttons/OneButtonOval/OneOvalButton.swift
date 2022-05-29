//
//  OneOvalButton.swift
//  UIOneComponents
//
//  Created by Adrian Arcalá Ocón on 3/1/22.
//

import CoreFoundationLib
import UI

public final class OneOvalButton: XibButton {
    
    @IBOutlet private weak var content: UIView!
    @IBOutlet private weak var imageButton: UIImageView!
    
    public override var isEnabled: Bool {
        didSet {
            let wasEnabled = oldValue
            if !wasEnabled, isEnabled {
                setStyle()
            } else if wasEnabled, !isEnabled {
                setDisableStyle() }
        }
    }
    public var style: OneOvalButtonStyle = .redWithWhiteTint {
        didSet { self.setStyle() }
    }
    public var size: OneOvalButtonSize = .large {
        didSet { self.setSize() }
    }
    public var direction: OneOvalButtonDirection = .right {
        didSet { self.setSize() }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    public func setAccessibilityIdentifier(key: String) {
        self.setAccessibilityIdentifiers(identifier: key)
    }
}

private extension OneOvalButton {
    
    func setupView() {
        self.setAccessibilityIdentifiers(identifier: "")
        self.setAppearence()
        self.subviews.forEach{ $0.isUserInteractionEnabled = false }
    }
    
    func setAppearence() {
        self.setSize()
        self.setStyle()
    }
    
    func setStyle() {
        switch self.style {
        case .redWithWhiteTint: self.setPrimaryStyle()
        case .whiteWithRedTint: self.setSecundaryStyle()
        case .whiteWithTurquoiseTint: self.setTerciaryStyle()
        case .disable: self.setDisableStyle()
        }
    }
    
    func setSize() {
        switch self.size {
        case .large: setLargeSize()
        case .medium: setMediumSize()
        case .small: setSmallSize()
        }
    }
    
    func setPrimaryStyle() {
        switch self.isEnabled {
        case true:
            self.content.backgroundColor = .oneSantanderRed
            self.imageButton.tintColor = .oneWhite
            self.content.setOneShadows(type: .oneShadowLarge)
        case false:
            self.content.backgroundColor = .oneBostonRed
            self.imageButton.tintColor = .oneWhite
            self.content.setOneShadows(type: .oneShadowLarge)
        }
    }
    
    func setSecundaryStyle() {
        switch self.isEnabled {
        case true:
            self.content.backgroundColor = .oneWhite
            self.imageButton.tintColor = .oneSantanderRed
            self.content.setOneShadows(type: .oneShadowLarge)
        case false:
            self.content.backgroundColor = .oneWhite
            self.imageButton.tintColor = .oneBostonRed
            self.content.setOneShadows(type: .oneShadowLarge)
        }
    }
    
    func setTerciaryStyle() {
        switch self.isEnabled {
        case true:
            self.content.backgroundColor = .oneWhite
            self.imageButton.tintColor = .oneTurquoise
            self.content.setOneShadows(type: .oneShadowLarge)
        case false:
            self.content.backgroundColor = .oneWhite
            self.imageButton.tintColor = .oneDarkTurquoise
            self.content.setOneShadows(type: .oneShadowLarge)
        }
    }
    
    func setDisableStyle() {
        self.content.backgroundColor = .oneLightGray40
        self.imageButton.tintColor = .oneLightSanGray
        self.content.setOneShadows(type: .none)
    }
    
    func setLargeSize() {
        self.content.bounds.size = CGSize(width: 64, height: 64)
        self.content.setOneCornerRadius(type: .oneShRadiusCircle)
        self.imageButton.image = Assets.image(named: "oneIcnArrowBtn")?.withRenderingMode(.alwaysTemplate)
        self.imageButton.bounds.size = CGSize(width: 24, height: 24)
    }
    
    func setMediumSize() {
        self.content.bounds.size = CGSize(width: 48, height: 48)
        self.content.setOneCornerRadius(type: .oneShRadiusCircle)
        self.imageButton.image = Assets.image(named: "oneIcnPlus")?.withRenderingMode(.alwaysTemplate)
        self.imageButton.bounds.size = CGSize(width: 20, height: 20)
    }
    
    func setSmallSize() {
        self.content.bounds.size = CGSize(width: 32, height: 32)
        self.content.setOneCornerRadius(type: .oneShRadiusCircle)
        switch self.direction {
        case .left:
            self.imageButton.image = Assets.image(named: "oneIcnArrowRoundedLeft")?.withRenderingMode(.alwaysTemplate)
        case .right:
            self.imageButton.image = Assets.image(named: "oneIcnArrowRoundedRight")?.withRenderingMode(.alwaysTemplate)
        case .up:
            self.imageButton.image = Assets.image(named: "oneIcnArrowRoundedUp")?.withRenderingMode(.alwaysTemplate)
        case .down:
            self.imageButton.image = Assets.image(named: "oneIcnArrowRoundedDown")?.withRenderingMode(.alwaysTemplate)
        case .plus:
            self.imageButton.image = Assets.image(named: "oneIcnPlus")?.withRenderingMode(.alwaysTemplate)
        }
        self.imageButton.bounds.size = CGSize(width: 16, height: 16)
    }
    func setAccessibilityIdentifiers(identifier: String?) {
        self.imageButton.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
        self.accessibilityIdentifier = identifier ?? ""
    }
}

public extension OneOvalButton {
    enum OneOvalButtonStyle {
        case redWithWhiteTint
        case whiteWithRedTint
        case whiteWithTurquoiseTint
        case disable
    }

    enum OneOvalButtonSize {
        case large
        case medium
        case small
    }

    enum OneOvalButtonDirection {
        case left
        case right
        case up
        case down
        case plus
    }
}
