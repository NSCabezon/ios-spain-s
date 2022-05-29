//
//  OneShortcutButton.swift
//  UIOneComponents
//
//  Created by Laura Gonzalez Salvador on 15/2/22.
//

import UI
import CoreFoundationLib
import UIKit

// MARK: - Layout Constants

private enum LayoutConstants {
    static let cornerRadiusType: OneCornerRadiusType = .oneShRadius4
    static let shadowType: OneShadowsType = .oneShadowLarge
    static let disabledBackgroundColor: UIColor = .oneLightGray40
    static let tagLabelFont: FontName = .oneB100Bold
    static let tagLabelColor: UIColor = .white
    static let tagOfferLabelColor: UIColor = .oneBrownGray
    static let tagBackgroundColor: UIColor = .oneDarkTurquoise
    static let tagOfferBackgroundColor: UIColor = .oneSkyGray
}

public struct OneShortcutButtonConfiguration {
    public let title: String?
    public let icon: String?
    public let iconTintColor: UIColor?
    public let backgroundColor: UIColor
    public let backgroundImage: String?
    public let offerImage: OfferImageViewActionButtonViewModel?
    public let tagTitle: String?
    public let accessibilitySuffix: String?
    public let isDisabled: Bool
    public let action: (() -> Void)?
    
    public init(title:String? = nil,
                icon: String? = nil,
                iconTintColor: UIColor? = nil,
                backgroundColor: UIColor = .oneWhite,
                backgroundImage: String? = nil,
                offerImage: OfferImageViewActionButtonViewModel? = nil,
                tagTitle: String? = nil,
                accessibilitySuffix: String? = nil,
                isDisabled: Bool,
                action: (() -> Void)?) {
        self.title = title
        self.icon = icon
        self.iconTintColor = iconTintColor
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.offerImage = offerImage
        self.tagTitle = tagTitle
        self.accessibilitySuffix = accessibilitySuffix
        self.isDisabled = isDisabled
        self.action = action
    }
}

// MARK: - OneShortcutButton

public final class OneShortcutButton: XibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var buttonContainer: UIView!
    @IBOutlet private weak var tagContainer: UIView!
    @IBOutlet private weak var tagLabel: UILabel!
    private var customAction: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
}

// MARK: - Public functions

public extension OneShortcutButton {
    func setAccessibilitySuffix(_ suffix: String? = nil) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    func setViewModel(configuration: OneShortcutButtonConfiguration, hasHorizontalStyle: Bool) {
        self.configureTag(tagTitle: configuration.tagTitle, isOfferButton: configuration.offerImage != nil)
        self.configureContentView(configuration: configuration, hasHorizontalStyle: hasHorizontalStyle)
        self.setAccessibilitySuffix(configuration.accessibilitySuffix)
        guard let action = configuration.action else { return }
        self.addAction(action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.buttonContainer.backgroundColor = .oneSkyGray
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.buttonContainer.backgroundColor = .oneWhite
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.buttonContainer.backgroundColor = .oneWhite
    }
}

// MARK: - Private Configurations

private extension OneShortcutButton {
    func configureView() {
        self.configureTagContainer()
        self.configureRadius()
    }
    
    func configureRadius() {
        self.contentView.setOneCornerRadius(type: LayoutConstants.cornerRadiusType)
        self.buttonContainer.setOneCornerRadius(type: LayoutConstants.cornerRadiusType)
    }
    
    func configureTagContainer() {
        self.tagLabel.textColor = LayoutConstants.tagLabelColor
        self.tagLabel.font = UIFont.typography(fontName: LayoutConstants.tagLabelFont)
        tagContainer.backgroundColor = LayoutConstants.tagBackgroundColor
        tagContainer.isHidden = false
    }
    
    func configureTag(tagTitle: String?, isOfferButton: Bool) {
        if let tagTitle = tagTitle {
            tagLabel.text = localized(tagTitle).text
            self.tagContainer.setOneCornerRadius(type: LayoutConstants.cornerRadiusType)
            if isOfferButton {
                self.tagContainer.backgroundColor = LayoutConstants.tagOfferBackgroundColor
                self.tagLabel.textColor = LayoutConstants.tagOfferLabelColor
            }
        } else {
            tagContainer.isHidden = true
        }
    }
    
    func configureContentView(configuration: OneShortcutButtonConfiguration, hasHorizontalStyle: Bool) {
        if hasHorizontalStyle {
            setHorizontalView(configuration: configuration)
        } else if configuration.offerImage != nil {
            setOfferButtonView(configuration: configuration)
        } else {
            setVerticalView(configuration: configuration)
        }
    }
    
    func setOfferButtonView(configuration: OneShortcutButtonConfiguration) {
        let buttonView = OneShortcutButtonOfferImage()
        buttonView.configureView(viewModel: configuration)
        buttonContainer.addSubview(buttonView)
        buttonView.fullFit()
        self.configureStatus(configuration: configuration)
        buttonView.setAccessibilitySuffix(configuration.accessibilitySuffix)
    }
    
    func setHorizontalView(configuration: OneShortcutButtonConfiguration) {
        let buttonView = OneShortcutButtonHorizontal()
        buttonView.configureView(viewModel: configuration)
        buttonContainer.addSubview(buttonView)
        buttonView.fullFit()
        self.configureStatus(configuration: configuration)
        buttonView.setAccessibilitySuffix(configuration.accessibilitySuffix)
    }
    
    func setVerticalView(configuration: OneShortcutButtonConfiguration) {
        let buttonView = OneShortcutButtonVertical()
        buttonView.configureView(viewModel: configuration)
        buttonContainer.addSubview(buttonView)
        buttonView.fullFit()
        self.configureStatus(configuration: configuration)
        buttonView.setAccessibilitySuffix(configuration.accessibilitySuffix)
    }
    
    func configureStatus(configuration: OneShortcutButtonConfiguration) {
        self.isUserInteractionEnabled = !configuration.isDisabled
        if configuration.isDisabled {
            applyDisabledStyle(configuration: configuration)
        } else {
            applyEnabledStyle(configuration: configuration)
        }
    }
    
    func applyEnabledStyle(configuration: OneShortcutButtonConfiguration) {
        self.buttonContainer.backgroundColor = configuration.backgroundColor
        self.contentView.setOneShadows(type: LayoutConstants.shadowType)
    }
    
    func applyDisabledStyle(configuration: OneShortcutButtonConfiguration) {
        if configuration.backgroundColor == .oneWhite {
            self.buttonContainer.backgroundColor = LayoutConstants.disabledBackgroundColor
        } else {
            self.buttonContainer.alpha = 0.5
        }
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.buttonContainer.accessibilityIdentifier = AccessibilityOneComponents.oneShortcutButton + (suffix ?? "")
        self.tagContainer.accessibilityIdentifier = AccessibilityOneComponents.oneShortcutButtonTag + (suffix ?? "")
        self.tagLabel.accessibilityIdentifier = AccessibilityOneComponents.oneShortcutButtonTagLabel + (suffix ?? "")
    }
    
    @objc func performCustomAction() {
        self.customAction?()
    }
    
    func addAction(_ action: @escaping () -> Void) {
        self.customAction = action
        let gesture = UITapGestureRecognizer(target: self, action: #selector(performCustomAction))
        self.addGestureRecognizer(gesture)
    }
}
