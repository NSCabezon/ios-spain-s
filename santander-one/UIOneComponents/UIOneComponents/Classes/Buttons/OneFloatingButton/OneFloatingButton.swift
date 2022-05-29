//
//  OneFloatingButton.swift
//  UI
//
//  Created by Juan Diego Vázquez Moreno on 26/7/21.
//

import UIKit
import UI
import CoreFoundationLib
import OpenCombine

private struct FloatingButtonLayoutConfig {
    let minWidth: CGFloat
    let height: CGFloat
    let spacing: (left: CGFloat, right: CGFloat)
    let labelsLineHeigh: (top: CGFloat, bottom: CGFloat?)
    let fonts: (top: UIFont, bottom: UIFont?)
    let textAlignment: NSTextAlignment
}

private enum LayoutConstants {
    static let keylockIcon: String = "icnSanKeyBtn"
    static let arrowIcon: String = "icnArrowBtn"
    static let shadowType: OneShadowsType = .oneShadowLarge
    static let defaultColor: UIColor = .oneBostonRed
    static let highlightColor: UIColor = .oneSantanderRed
    static let disabledBackgroundColor: UIColor = .white
    static let disabledItemsColor: UIColor = .oneLightSanGray
    static let smallLayoutConfig = FloatingButtonLayoutConfig(
        minWidth: 112,
        height: OneSpacingType.oneSizeSpacing32.value,
        spacing: (left: OneSpacingType.oneSizeSpacing16.value, right: OneSpacingType.oneSizeSpacing16.value),
        labelsLineHeigh: (top: OneSpacingType.oneSizeSpacing20.value, bottom: nil),
        fonts: (top: UIFont.typography(fontName: .oneB300Bold), bottom: nil),
        textAlignment: .center
    )
    static let mediumCompactNoIconLayoutConfig = FloatingButtonLayoutConfig(
        minWidth: 124,
        height: OneSpacingType.oneSizeSpacing48.value,
        spacing: (left: OneSpacingType.oneSizeSpacing24.value, right: OneSpacingType.oneSizeSpacing24.value),
        labelsLineHeigh: (top: OneSpacingType.oneSizeSpacing24.value, bottom: nil),
        fonts: (top: UIFont.typography(fontName: .oneB400Bold), bottom: nil),
        textAlignment: .center
    )
    static let mediumCompactRightIconLayoutConfig = FloatingButtonLayoutConfig(
        minWidth: 124,
        height: OneSpacingType.oneSizeSpacing48.value,
        spacing: (left: OneSpacingType.oneSizeSpacing24.value, right: OneSpacingType.oneSizeSpacing20.value),
        labelsLineHeigh: (top: OneSpacingType.oneSizeSpacing24.value, bottom: nil),
        fonts: (top: UIFont.typography(fontName: .oneB400Bold), bottom: nil),
        textAlignment: .center
    )
    static let mediumFullWidthNoIconLayoutConfig = FloatingButtonLayoutConfig(
        minWidth: 124,
        height: OneSpacingType.oneSizeSpacing48.value,
        spacing: (left: OneSpacingType.oneSizeSpacing24.value, right: OneSpacingType.oneSizeSpacing24.value),
        labelsLineHeigh: (top: OneSpacingType.oneSizeSpacing24.value, bottom: nil),
        fonts: (top: UIFont.typography(fontName: .oneB400Bold), bottom: nil),
        textAlignment: .center
    )
    static let mediumFullWidthRightIconLayoutConfig = FloatingButtonLayoutConfig(
        minWidth: 124,
        height: OneSpacingType.oneSizeSpacing48.value,
        spacing: (left: OneSpacingType.oneSizeSpacing24.value, right: OneSpacingType.oneSizeSpacing20.value),
        labelsLineHeigh: (top: OneSpacingType.oneSizeSpacing24.value, bottom: nil),
        fonts: (top: UIFont.typography(fontName: .oneB400Bold), bottom: nil),
        textAlignment: .left
    )
    static let largeCompactRightIconLayoutConfig = FloatingButtonLayoutConfig(
        minWidth: 160,
        height: OneSpacingType.oneSizeSpacing64.value,
        spacing: (left: OneSpacingType.oneSizeSpacing32.value, right: OneSpacingType.oneSizeSpacing16.value),
        labelsLineHeigh: (top: OneSpacingType.oneSizeSpacing24.value, bottom: OneSpacingType.oneSizeSpacing16.value),
        fonts: (top: UIFont.typography(fontName: .oneB400Bold), bottom: UIFont.typography(fontName: .oneB200Regular)),
        textAlignment: .right
    )
    static let largeFullWidthRightIconLayoutConfig = FloatingButtonLayoutConfig(
        minWidth: 160,
        height: OneSpacingType.oneSizeSpacing64.value,
        spacing: (left: OneSpacingType.oneSizeSpacing24.value, right: OneSpacingType.oneSizeSpacing20.value),
        labelsLineHeigh: (top: OneSpacingType.oneSizeSpacing24.value, bottom: OneSpacingType.oneSizeSpacing16.value),
        fonts: (top: UIFont.typography(fontName: .oneB400Bold), bottom: UIFont.typography(fontName: .oneB200Regular)),
        textAlignment: .left
    )
    static let largeFullWidthBothIconLayoutConfig = FloatingButtonLayoutConfig(
        minWidth: 160,
        height: OneSpacingType.oneSizeSpacing64.value,
        spacing: (left: OneSpacingType.oneSizeSpacing20.value, right: OneSpacingType.oneSizeSpacing20.value),
        labelsLineHeigh: (top: OneSpacingType.oneSizeSpacing24.value, bottom: OneSpacingType.oneSizeSpacing16.value),
        fonts: (top: UIFont.typography(fontName: .oneB400Bold), bottom: UIFont.typography(fontName: .oneB200Regular)),
        textAlignment: .left
    )
}

public extension OneFloatingButton {
    enum ButtonType {
        case primary, secondary
        
        fileprivate func backgroundColor(_ isHighlighted: Bool) -> UIColor {
            switch self {
            case .primary:
                return isHighlighted ? LayoutConstants.highlightColor : LayoutConstants.defaultColor
            case .secondary:
                return .white
            }
        }
        
        fileprivate func itemsColor(_ isHighlighted: Bool) -> UIColor {
            switch self {
            case .primary:
                return .white
            case .secondary:
                return isHighlighted ? LayoutConstants.highlightColor : LayoutConstants.defaultColor
            }
        }
    }
    
    enum ButtonSize {
        case small(SmallButtonConfig)
        case medium(MediumButtonConfig)
        case large(LargeButtonConfig)
        
        public struct SmallButtonConfig {
            public let title: String
            
            public init(title: String) {
                self.title = title
            }
        }
        
        public struct MediumButtonConfig {
            public let title: String
            public let icons: MediumIcons
            public let fullWidth: Bool
            
            public enum MediumIcons { case none, right }
            
            public init(title: String, icons: MediumIcons, fullWidth: Bool) {
                self.title = title
                self.icons = icons
                self.fullWidth = fullWidth
            }
        }
        
        public struct LargeButtonConfig {
            public let title: String
            public let subtitle: String
            public let icons: LargeIcons
            public let fullWidth: Bool
            
            public enum LargeIcons { case right, both }
            
            public init(title: String, subtitle: String, icons: LargeIcons, fullWidth: Bool) {
                self.title = title
                self.subtitle = subtitle
                self.icons = icons
                self.fullWidth = fullWidth
            }
        }
        
        fileprivate var title: String {
            switch self {
            case .small(let config):
                return config.title
            case .medium(let config):
                return config.title
            case .large(let config):
                return config.title
            }
        }
        
        fileprivate var subtitle: String? {
            switch self {
            case .small, .medium:
                return nil
            case .large(let config):
                return config.subtitle
            }
        }
        
        fileprivate var layoutConfig: FloatingButtonLayoutConfig? {
            switch self {
            case .small:
                return LayoutConstants.smallLayoutConfig
                
            case .medium(let config):
                if config.fullWidth {
                    return (config.icons == .none) ?
                    LayoutConstants.mediumFullWidthNoIconLayoutConfig :
                    LayoutConstants.mediumFullWidthRightIconLayoutConfig
                } else {
                    return (config.icons == .none) ?
                    LayoutConstants.mediumCompactNoIconLayoutConfig :
                    LayoutConstants.mediumCompactRightIconLayoutConfig
                }
                
            case .large(let config):
                if config.fullWidth {
                    return (config.icons == .right) ?
                    LayoutConstants.largeFullWidthRightIconLayoutConfig :
                    LayoutConstants.largeFullWidthBothIconLayoutConfig
                } else {
                    return (config.icons == .right) ?
                    LayoutConstants.largeCompactRightIconLayoutConfig :
                    nil
                }
            }
        }
    }
    
    enum ButtonStatus {
        case ready, loading
    }
    
    enum ButtonState: CoreFoundationLib.State {
        case available
        case disabled
    }
}

public enum OneFloatingButtonState: State {
    case idle
    case isFocused
}

public final class OneFloatingButton: XibButton {
    @IBOutlet private weak var leftImageView: UIImageView!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var rightImageView: UIImageView!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var borderContentView: UIView!
    @IBOutlet private var leadingWidthEqualConstraint: NSLayoutConstraint!
    @IBOutlet private var leadingWidthGreaterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var loadingImageView: UIImageView!
    private var accessibilitySuffix: String = ""
    public let buttonStateSubject = CurrentValueSubject<ButtonState, Never>(.available)
    var buttonState: AnyPublisher<ButtonState, Never>
    public let onTouchSubject = PassthroughSubject<Void, Never>()
    private var anySubscriptions = Set<AnyCancellable>()
    
    private var floatingButtonType: ButtonType = .primary {
        didSet {
            self.setTypeAppearance()
        }
    }
    
    private var buttonSize: ButtonSize = .small(ButtonSize.SmallButtonConfig(title: "small button")) {
        didSet {
            self.setLabels()
            self.setSizeAppearance()
        }
    }
    
    private var buttonStatus: ButtonStatus = .ready {
        didSet {
            self.setStatusAppearance()
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted { setHighlightedAppearance() }
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            setEnabledStatusAppearance()
        }
    }
    
    public override init(frame: CGRect){
        buttonState = buttonStateSubject.eraseToAnyPublisher()
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        buttonState = buttonStateSubject.eraseToAnyPublisher()
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
        self.setAccessibilityIdentifiers()
        bind()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.borderContentView.setOneCornerRadius(type: .oneShRadiusCircle)
    }
    
    private func configureView() {
        self.backgroundColor = .clear
        self.borderContentView.setOneShadows(type: LayoutConstants.shadowType)
        self.leftImageView.image = Assets.image(named: LayoutConstants.keylockIcon)?.withRenderingMode(.alwaysTemplate)
        self.leftImageView.isHidden = true
        self.rightImageView.isHidden = true
        self.configureWith(type: self.floatingButtonType, size: self.buttonSize, status: self.buttonStatus)
        self.subviews.forEach{ $0.isUserInteractionEnabled = false }
    }
    
    public func configureWith(type: ButtonType, size: ButtonSize, status: ButtonStatus) {
        self.floatingButtonType = type
        self.buttonSize = size
        self.buttonStatus = status
    }
    
    public func setAccessibilitySuffix(_ suffix: String) {
        self.accessibilitySuffix = suffix
        self.setAccessibilityIdentifiers(suffix)
    }
    
    public func getTitle() -> String? {
        return topLabel.text
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard isEnabled else { return }
        onTouchSubject.send()
    }
    
    public func setRightImage(image: String) {
        self.rightImageView.image = Assets.image(named: image)?.withRenderingMode(.alwaysTemplate)
    }
    
    public func setLeftImage(_ image: String) {
        self.leftImageView.image = Assets.image(named: image)?.withRenderingMode(.alwaysTemplate)
    }
}

public extension OneFloatingButton {
    func setLoadingStatus(_ status: ButtonStatus) {
        if self.buttonStatus != status {
            self.buttonStatus = status
        }
    }
}

private extension OneFloatingButton {
    func bind() {
        buttonStateSubject
            .sink { [unowned self] status in
                self.isEnabled = status == .available
            }.store(in: &anySubscriptions)
    }
    
    func setTypeAppearance() {
        self.setColorsAppearance(backgroundColor: self.floatingButtonType.backgroundColor(self.isHighlighted),
                                 itemsColor: self.floatingButtonType.itemsColor(self.isHighlighted))
    }
    
    func setLabels() {
        self.topLabel.text = localized(self.buttonSize.title)
        if let subTitle = self.buttonSize.subtitle {
            self.bottomLabel.text = localized(subTitle)
        }
        self.bottomLabel.isHidden = self.buttonSize.subtitle == nil
    }
    
    func setSizeAppearance() {
        guard let layoutConfig = self.buttonSize.layoutConfig else { return }
        self.topLabel.isHidden = false
        self.topLabel.font = layoutConfig.fonts.top
        self.topLabel.textAlignment = layoutConfig.textAlignment
        self.topLabelHeightConstraint.constant = layoutConfig.labelsLineHeigh.top
        if let bottomLabelFont = layoutConfig.fonts.bottom, let bottomLabelHeight = layoutConfig.labelsLineHeigh.bottom {
            self.bottomLabel.font = bottomLabelFont
            self.bottomLabel.textAlignment = layoutConfig.textAlignment
            self.bottomLabelHeightConstraint.constant = bottomLabelHeight
        }
        self.leadingConstraint.constant = layoutConfig.spacing.left
        self.trailingConstraint.constant = layoutConfig.spacing.right
        self.leadingWidthEqualConstraint.isActive = false
        self.leadingWidthGreaterConstraint.isActive = true
        self.loadingImageView.isHidden = true
        switch self.buttonSize {
        case .small:
            self.leftImageView.isHidden = true
            self.rightImageView.isHidden = true
            
        case .medium(let config):
            if config.icons == .right {
                self.leftImageView.isHidden = true
                self.rightImageView.isHidden = false
            } else if config.icons == .none {
                self.leftImageView.isHidden = true
                self.rightImageView.isHidden = true
            }
            if config.fullWidth {
                self.leadingWidthEqualConstraint.isActive = true
                self.leadingWidthGreaterConstraint.isActive = false
            }
            
        case .large(let config):
            if config.icons == .both {
                self.leftImageView.isHidden = false
                self.rightImageView.isHidden = false
            } else if config.icons == .right {
                self.leftImageView.isHidden = true
                self.rightImageView.isHidden = false
            }
            if config.fullWidth {
                self.leadingWidthEqualConstraint.isActive = true
                self.leadingWidthGreaterConstraint.isActive = false
            }
        }
        
        self.widthConstraint.constant = (layoutConfig.minWidth - self.leadingConstraint.constant - self.trailingConstraint.constant)
        self.heightConstraint.constant = layoutConfig.height
    }
    
    func setStatusAppearance() {
        switch self.buttonSize {
        case .small:
            self.setCenteredLoader()
        case .medium(let configuration):
            if configuration.icons == .none {
                self.setCenteredLoader()
            } else {
                self.setRightIconLoader()
            }
        case .large:
            self.setRightIconLoader()
        }
        self.setAccessibilityIdentifiers(self.accessibilitySuffix)
    }
    
    func setCenteredLoader() {
        switch self.buttonStatus {
        case .ready:
            self.topLabel.isHidden = false
            self.loadingImageView.isHidden = true
            self.loadingImageView.removeLoader()
        case .loading:
            self.topLabel.isHidden = true
            self.loadingImageView.removeLoader()
            if self.floatingButtonType == .primary {
                self.loadingImageView.setWhiteJumpingLoader()
            } else {
                self.loadingImageView.setRedJumpingLoader()
            }
            self.loadingImageView.isHidden = false
        }
    }
    
    func setRightIconLoader() {
        switch self.buttonStatus {
        case .ready:
            self.rightImageView.removeLoader()
            self.rightImageView.image = Assets.image(named: LayoutConstants.arrowIcon)?.withRenderingMode(.alwaysTemplate)
        case .loading:
            self.rightImageView.removeLoader()
            self.rightImageView.image = nil
            if self.floatingButtonType == .primary {
                self.rightImageView.setWhiteJumpingLoader()
            } else {
                self.rightImageView.setRedJumpingLoader()
            }
        }
    }
    
    func setHighlightedAppearance() {
        setTypeAppearance()
    }
    
    func setEnabledStatusAppearance() {
        if isEnabled {
            setTypeAppearance()
        } else {
            setColorsAppearance(backgroundColor: LayoutConstants.disabledBackgroundColor,
                                itemsColor: LayoutConstants.disabledItemsColor)
        }
    }
    
    func setColorsAppearance(backgroundColor: UIColor, itemsColor: UIColor) {
        self.borderContentView.backgroundColor = backgroundColor
        self.leftImageView.tintColor = itemsColor
        self.rightImageView.tintColor = itemsColor
        self.topLabel.textColor = itemsColor
        self.bottomLabel.textColor = itemsColor
    }
    
    func setAccessibilityIdentifiers(_ suffix: String = "") {
        self.accessibilityIdentifier = AccessibilityOneComponents.oneFloatingButton + suffix
        self.topLabel.accessibilityIdentifier = AccessibilityOneComponents.oneFloatingButtonTopLabel + suffix
        self.bottomLabel.accessibilityIdentifier = AccessibilityOneComponents.oneFloatingButtonBottomLabel + suffix
        self.leftImageView.accessibilityIdentifier = AccessibilityOneComponents.oneFloatingButtonLeftIcn + suffix
        self.loadingImageView.accessibilityIdentifier = AccessibilityOneComponents.oneFloatingButtonLoader + suffix
        switch self.buttonStatus {
        case .ready:
            self.rightImageView.accessibilityIdentifier = AccessibilityOneComponents.oneFloatingButtonRightIcn + suffix
        case .loading:
            self.rightImageView.accessibilityIdentifier = AccessibilityOneComponents.oneFloatingButtonLoader + suffix
        }
    }
}
