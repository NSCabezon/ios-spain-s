//
//  OptionButton.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/28/19.
//

import UIKit
import CoreFoundationLib

public struct ActionButtonStyle {
    let backgroundColor: UIColor
    let selectedBackgroundColor: UIColor
    let imageTintColor: UIColor
    let textColor: UIColor
    let borderColor: UIColor
    let shadow: (color: UIColor, alpha: Float)
    let emptyShadow: UIColor
    let shadowRadius: CGFloat
    let shadowOffset: CGSize
    let imageIconSize: (width: CGFloat, height: CGFloat)?
    let textHeight: CGFloat?
    let textFont: UIFont?

    public init(backgroundColor: UIColor,
                selectedBackgroundColor: UIColor,
                imageTintColor: UIColor,
                textColor: UIColor,
                borderColor: UIColor,
                shadow: (color: UIColor, alpha: Float),
                emptyShadow: UIColor,
                shadowRadius: CGFloat = 2,
                shadowOffset: CGSize = CGSize(width: 1, height: 1),
                imageIconSize: (width: CGFloat, height: CGFloat)? = nil,
                textHeight: CGFloat? = nil,
                textFont: UIFont? = nil) {
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.imageTintColor = imageTintColor
        self.textColor = textColor
        self.borderColor = borderColor
        self.shadow = shadow
        self.emptyShadow = emptyShadow
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.imageIconSize = imageIconSize
        self.textHeight = textHeight
        self.textFont = textFont
    }

    public static let defaultStyleWithGrayBorder = ActionButtonStyle(backgroundColor: UIColor.white, selectedBackgroundColor: .bg, imageTintColor: UIColor.botonRedLight, textColor: UIColor.lisboaGray, borderColor: UIColor.mediumSkyGray, shadow: (UIColor.mediumSkyGray, Float(0.7)), emptyShadow: .skyGray)
    public static let smartBarStyle = ActionButtonStyle(backgroundColor: UIColor.clear, selectedBackgroundColor: UIColor.white.withAlphaComponent(0.2), imageTintColor: UIColor.white, textColor: UIColor.white, borderColor: UIColor.clear, shadow: (UIColor.clear, Float(0.0)), emptyShadow: .clear)
    public static let smartShortcutSelectorStyle = ActionButtonStyle(backgroundColor: UIColor.burgundy, selectedBackgroundColor: UIColor.burgundy, imageTintColor: UIColor.white, textColor: UIColor.white, borderColor: UIColor.clear, shadow: (UIColor.clear, Float(0.0)), emptyShadow: .lightBurgundy)
    public static let smartBlackShortcutSelectorStyle = ActionButtonStyle(backgroundColor: UIColor.metal, selectedBackgroundColor: UIColor.metal, imageTintColor: UIColor.white, textColor: UIColor.white, borderColor: UIColor.clear, shadow: (UIColor.clear, Float(0.0)), emptyShadow: .grafite)
    public static let smartSelectorStyle = ActionButtonStyle(backgroundColor: UIColor.white.withAlphaComponent(0.2), selectedBackgroundColor: UIColor.white.withAlphaComponent(0.2), imageTintColor: UIColor.white, textColor: UIColor.white, borderColor: UIColor.clear, shadow: (UIColor.clear, Float(0.0)), emptyShadow: .clear)
    public static let defaultStyleWithGrayBackground = ActionButtonStyle(backgroundColor: UIColor.white, selectedBackgroundColor: .mediumSkyGray, imageTintColor: UIColor.botonRedLight, textColor: UIColor.lisboaGray, borderColor: UIColor.mediumSkyGray, shadow: (UIColor.mediumSkyGray, Float(0.7)), emptyShadow: .clear)
    public static let remarkableStyle = ActionButtonStyle(backgroundColor: UIColor.darkTorquoise, selectedBackgroundColor: UIColor.darkTorquoise, imageTintColor: UIColor.white, textColor: UIColor.white, borderColor: UIColor.mediumSkyGray, shadow: (UIColor.skyGray, Float(0.7)), emptyShadow: .skyGray)
    public static let defaultStyleForBackground = ActionButtonStyle(backgroundColor: UIColor.white, selectedBackgroundColor: .bg, imageTintColor: UIColor.botonRedLight, textColor: UIColor.white, borderColor: UIColor.clear, shadow: (UIColor.deepRed, 0.7), emptyShadow: .skyGray)
}

protocol ActionButtonFillViewProtocol: UIView {
    func setDragIconVisibility(isHidden: Bool)
    func applyDisabledStyle()
    func applyEnabledStyle()
    func setAppearance(withStyle style: ActionButtonStyle)
}

public class ActionButton: UIView {
    private var view: UIView!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var extraTopLabelContainer: UIView!
    @IBOutlet weak var extraTopLabel: UILabel!
    weak var fillView: ActionButtonFillViewProtocol?
    
    private var customAction: (() -> Void)?
    private var viewModel: ActionButtonFillViewModelProtocol?
    var style: ActionButtonStyle = ActionButtonStyle.defaultStyleWithGrayBorder
    var highlightedInfo: HighlightedInfo?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard extraTopLabel.text != localized("generic_alert_notAvailableOperation").uppercased() else { return }
        self.buttonContainer.backgroundColor = style.selectedBackgroundColor
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard extraTopLabel.text != localized("generic_alert_notAvailableOperation").uppercased() else { return }
        self.buttonContainer.backgroundColor = style.backgroundColor
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard extraTopLabel.text != localized("generic_alert_notAvailableOperation").uppercased() else { return }
        self.buttonContainer.backgroundColor = style.backgroundColor
    }
    
    public func addSelectorAction(target: Any?, _ action: Selector) {
        let gesture = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(gesture)
    }
    
    public func addAction(_ action: @escaping () -> Void) {
        self.customAction = action
        let gesture = UITapGestureRecognizer(target: self, action: #selector(performCustomAction))
        self.addGestureRecognizer(gesture)
    }
    
    public func setExtraLabelContent(_ content: HighlightedInfo?,
                                     shouldHideForAnimation: Bool = false) {
        highlightedInfo = content
        guard let content = content,
              !content.text.isEmpty,
              let textColor = content.style?.textColor,
              let borderColor = content.style?.borderColor,
              let backgroundColor = content.style?.backgroundColor
        else {
            extraTopLabelContainer.isHidden = true
            extraTopLabel.text = ""
            extraTopLabel.isAccessibilityElement = false
            return
        }
        extraTopLabelContainer.alpha = shouldHideForAnimation ? 0.0: 1.0
        extraTopLabelContainer.isHidden = false
        extraTopLabel.text = content.text.uppercased()
        extraTopLabel.textColor = textColor
        extraTopLabel.isAccessibilityElement = false
        extraTopLabelContainer.backgroundColor = backgroundColor
        extraTopLabelContainer.layer.borderColor = borderColor.cgColor
        extraTopLabelContainer.layer.borderWidth = 1
        extraTopLabelContainer.layer.cornerRadius = 2
    }

    public func animateExtraLabelContent(withDelay delay: Double, offset: Double) {
        guard !extraTopLabelContainer.isHidden else { return }
        UIView.animate(withDuration: delay, delay: offset, options: [], animations: {
            self.extraTopLabelContainer.alpha = 1.0
        }, completion: nil)
    }

    public func setViewModel(_ viewModel: ActionButtonFillViewModelProtocol?, isDragDisabled: Bool = false) {
        guard let viewModel = viewModel,
              let newFillView = ActionButtonFullViewBuilder.build(for: viewModel.viewType, isDragDisabled: isDragDisabled)
        else { return }
        self.viewModel = viewModel
        if fillView != nil {
            fillView?.removeFromSuperview()
        }
        buttonContainer.addSubview(newFillView)
        newFillView.fullFit()
        if case .defaultWithBackground(let mode) = viewModel.viewType {
            setAppearance(withStyle: ActionButtonStyle.defaultStyleForBackground)
            buttonContainer.accessibilityIdentifier = "summaryOperativeButton\(mode.titleAccessibilityIdentifier)"
        }
        newFillView.setAppearance(withStyle: self.style)
        newFillView.setDragIconVisibility(isHidden: true)
        self.fillView = newFillView
        self.setAccesibilityValue()
    }

    public func getViewModel() -> ActionButtonFillViewModelProtocol? {
        return self.viewModel
    }

    public func setIsDisabled(_ isDisabled: Bool) {
        self.isUserInteractionEnabled = !isDisabled
        if isDisabled {
            self.applyDisabledStyle()
        } else {
            self.applyEnabledStyle()
        }
    }
    
    public func checkEnabledStyle() {
        self.isUserInteractionEnabled ? applyEnabledStyle() : applyDisabledStyle()
    }

    public func grayAppearance() {
        self.setAppearance(withStyle: .defaultStyleWithGrayBorder)
    }
    
    public func torquoiseAppearance() {
        self.setAppearance(withStyle: .remarkableStyle)
    }
    
    public func setAppearance(withStyle style: ActionButtonStyle) {
        self.style = style
        self.view.backgroundColor = .clear
        self.buttonContainer.backgroundColor = style.backgroundColor
        self.buttonContainer.layer.borderWidth = 1
        self.buttonContainer.layer.borderColor = style.borderColor.cgColor
        self.buttonContainer.layer.cornerRadius = 5
        self.buttonContainer.layer.shadowColor = style.shadow.color.cgColor
        self.buttonContainer.layer.shadowRadius = style.shadowRadius
        self.buttonContainer.layer.shadowOpacity = style.shadow.alpha
        self.buttonContainer.layer.shadowOffset = style.shadowOffset
        self.extraTopLabelContainer.layer.cornerRadius = 2
        self.extraTopLabel.font = UIFont.santander(family: .text, type: .bold, size: 9)
        self.fillView?.setAppearance(withStyle: style)
    }
}

private extension ActionButton {
    func setupView() {
        self.xibSetup()
        self.applyEnabledStyle()
        setAppearance(withStyle: style)
    }

    func xibSetup() {
        self.backgroundColor = .clear
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.backgroundColor = .clear
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func applyDisabledStyle() {
        if style.textColor == ActionButtonStyle.defaultStyleWithGrayBorder.textColor {
            self.buttonContainer.backgroundColor = UIColor.silverDark
        } else {
            self.buttonContainer.alpha = 0.6
        }
        self.fillView?.applyDisabledStyle()
    }

    func applyEnabledStyle() {
        self.buttonContainer.backgroundColor = style.backgroundColor
        self.fillView?.applyEnabledStyle()
    }
    
    @objc func performCustomAction() {
        self.customAction?()
    }
    
    func setAccesibilityValue() {
        self.accessibilityTraits = .button
        guard let viewModel = self.viewModel,
              let buttonAccessibilityValue = viewModel.getAccessibilityValue() else { return }
        if let accesibilityId = viewModel.getAccessibilityIdentifier() {
            self.accessibilityIdentifier = accesibilityId
        } else {
            self.isAccessibilityElement = false
            self.accessibilityIdentifier = "btn_\(buttonAccessibilityValue)"
            self.accessibilityValue = localized(buttonAccessibilityValue)
        }
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
