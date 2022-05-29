//
//  OneToggleXibView.swift
//  UIOneComponents
//
//  Created by Jose Javier Montes Romero on 28/2/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine

public enum OneSizeToggleView: CGFloat {
    case widthSmall = 37
    case widthNormal = 43
    case heitghtSmall = 24
    case heitghtNormal = 28
}

private extension OneToggleView {}

public final class OneToggleView: XibView {
    private var subject = PassthroughSubject<Bool, Never>()
    public lazy var publisher: AnyPublisher<Bool, Never> = {
        return subject.eraseToAnyPublisher()
    }()
    private var subscriptions = Set<AnyCancellable>()
    @IBOutlet private weak var switchView: OneToggleSwitch!
    @IBOutlet private weak var widthSwitchConstraint: NSLayoutConstraint!
    @IBOutlet private weak var heightSwitchConstraint: NSLayoutConstraint!
    public var oneSize: OneToggleViewSize = .small {
        didSet { self.setSize() }
    }
    public var isEnabled: Bool = true {
        didSet {
            isEnabled ? setEnabledStyle() : setDisabledStyle()
        }
    }
    public var isOn: Bool {
        get{
            return self.switchView.isOn
        }
        set (newValue) {
            self.switchView.setOn(on: newValue, animated: false)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

private extension OneToggleView {
    func setupView() {
        setSize()
        setEnabledStyle()
        switchView.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.touchUpInside)
        setAccessibilityIdentifiers()
    }
    
    @objc func switchChanged() {
        subject.send(switchView.isOn)
    }
    
    func setSize() {
        switch self.oneSize {
        case .small:
            setSmallSize()
        case .big:
            setNormalSize()
            setImages()
        }
    }

    func setEnabledStyle() {
        self.switchView.onTintColor = .oneDarkTurquoise
        self.switchView.thumbTintColor = .oneWhite
        self.switchView.offTintColor = .oneBrownGray
        self.switchView.isUserInteractionEnabled = true
        if self.oneSize == .big {
            self.setImages()
        }
    }

    func setDisabledStyle() {
        self.switchView.thumbTintColor = .oneLightSanGray
        self.switchView.offTintColor = .oneLightGray40
        self.switchView.isUserInteractionEnabled = false
        self.switchView.setOn(on: false, animated: false)
        self.removeImages()
    }

    func setSmallSize() {
        self.widthSwitchConstraint.constant = OneSizeToggleView.widthSmall.rawValue
        self.heightSwitchConstraint.constant = OneSizeToggleView.heitghtSmall.rawValue
        self.layoutIfNeeded()
    }

    func setNormalSize() {
        self.widthSwitchConstraint.constant = OneSizeToggleView.widthNormal.rawValue
        self.heightSwitchConstraint.constant = OneSizeToggleView.heitghtNormal.rawValue
    }
    
    func setImages() {
        if isEnabled {
            self.switchView.offImage = Assets.image(named: "oneToogleOff")?.withRenderingMode(.alwaysOriginal)
            self.switchView.onImage = Assets.image(named: "oneToogleOn")?.withRenderingMode(.alwaysOriginal)
            self.layoutIfNeeded()
        }
    }
    
    func removeImages() {
        self.switchView.offImage = nil
        self.switchView.onImage = nil
        self.layoutIfNeeded()
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.switchView?.accessibilityIdentifier = AccessibilityOneComponents.oneToggleView + (suffix ?? "")
    }
}

public extension OneToggleView {
    enum OneToggleViewSize {
        case small
        case big
    }
}
