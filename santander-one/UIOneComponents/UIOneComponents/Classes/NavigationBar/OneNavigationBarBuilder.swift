import UIKit
import UI

public final class OneNavigationBarBuilder {
    private let style: OneNavigationBarStyle
    private var leftButtonModel: OneNavigationBarLeftButtonModel?
    private var leftButtonAction: (() -> Void)?
    private var rightButtonsModels: [(info: OneNavigationBarButtonModel, completion: () -> Void)] = []
    private var titleKey: String?
    private var tooltipAction: ((UIView) -> Void)?
    private var tooltipAccessibilityLabelKey: String?
    private var accessibilityTitleLabelKey: String?
    private var accessibilityTitleValue: String?
    private var accessibilityTitleHint: String?
    private var viewController: UIViewController!
    private var oneNavigationBarTitleImage: OneNavigationBarTitleImage?
    private var titleConfiguration: LocalizedStylableTextConfiguration?
    
    public init(_ style: OneNavigationBarStyle) {
        self.style = style
    }
    
    public func setLeftAction(_ model: OneNavigationBarLeftButtonModel, customAction: (() -> Void)? = nil) -> Self {
        self.leftButtonModel = model
        self.leftButtonAction = customAction
        return self
    }
    
    public func setRightAction(_ model: OneNavigationBarButtonModel, action: @escaping () -> Void) -> Self  {
        self.rightButtonsModels.append((model, action))
        return self
    }
    
    public func setTitle(withKey key: String) -> Self {
        self.titleKey = key
        return self
    }
    
    public func setAccessibilityTitleLabel(withKey key: String) -> Self {
        self.accessibilityTitleLabelKey = key
        return self
    }
    
    public func setAccessibilityTitleValue(value: String) -> Self {
        self.accessibilityTitleValue = value
        return self
    }
    
    public func setAccessibilityTitleHint(hint: String) -> Self {
        self.accessibilityTitleHint = hint
        return self
    }
    
    public func setTooltip(_ action: @escaping (UIView) -> Void) -> Self {
        self.tooltipAction = action
        return self
    }
    
    public func setTooltipAccessibilityLabel(withKey key: String) -> Self {
        self.tooltipAccessibilityLabelKey = key
        return self
    }
    
    public func setTitleImage(withKey key: String) -> Self {
        self.oneNavigationBarTitleImage = .key(key)
        return self
    }
    
    public func setTitleImage(withTitleImage titleImage: OneNavigationBarTitleImage?) -> Self {
        self.oneNavigationBarTitleImage = titleImage
        return self
    }
    
    public func setTitleConfiguration(withConfiguration titleConfiguration: LocalizedStylableTextConfiguration?) -> Self {
        self.titleConfiguration = titleConfiguration
        return self
    }
    
    public func build(on viewController: UIViewController) {
        self.viewController = viewController
        switch self.style {
        case .transparentWithWhiteComponents:
            self.setClearBarTintColor()
        case .whiteWithRedComponents:
            self.setBarTintColor(.white)
        }
        self.buildLeftButton()
        self.buildRightButtons()
        self.buildTitle()
        self.legacyCompatibilityWithMadridNavigationBar()
    }
}

// MARK: Buttons Actions
private extension OneNavigationBarBuilder {
    func buildLeftButton() {
        guard let model = self.leftButtonModel else {
            self.hideBackButton()
            return
        }
        switch model {
        case .back:
            self.buildBackButton()
        case .santanderLogo(let logo):
            self.buildSantanderLogo(logo)
        }
    }
    
    func buildBackButton() {
        let backCompletion: () -> Void = {
            self.viewController.navigationController?.popViewController(animated: !UIAccessibility.isVoiceOverRunning)
        }
        self.viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: self.createImageTextView(
                icnKey: "oneIcnBack",
                title: "generic_label_back",
                accesibilityLabelKey: "voiceover_returnPreviousScreen",
                action: self.leftButtonAction ?? backCompletion
            )
        )
        self.viewController.navigationItem.leftItemsSupplementBackButton = false
        self.viewController.navigationController?.interactivePopGestureRecognizer?.delegate = (self.viewController as? UIGestureRecognizerDelegate)
    }
    
    func buildSantanderLogo(_ logo: OneNavigationBarSantanderLogo) {
        self.viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: SantanderIconView(
                model: SantanderIconViewModel(
                    style: self.style,
                    logo: logo,
                    action: self.leftButtonAction
                )
            )
        )
    }
    
    func hideBackButton() {
        self.viewController.navigationItem.hidesBackButton = true
    }
    
    func buildRightButtons() {
        var buttons: [UIView] = []
        for model in rightButtonsModels {
            buttons.append(
                createImageTextView(
                    icnKey: model.info.imageKey,
                    title: model.info.text,
                    accesibilityLabelKey: model.info.accessibilityLabelKey,
                    action: model.completion
                )
            )
        }
        let rightStackView = UIStackView(
            arrangedSubviews: buttons
        )
        rightStackView.axis = .horizontal
        rightStackView.spacing = 24
        self.viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightStackView)
    }
    
    func createImageTextView(icnKey: String, title: String, accesibilityLabelKey: String, action: @escaping () -> Void) -> ImageTextView {
        return ImageTextView(
            ImageTextViewModel(
                style: self.style,
                imageKey: icnKey,
                titleKey: title,
                accesibilityLabelKey: accesibilityLabelKey,
                action: action
            )
        )
    }
    
    func legacyCompatibilityWithMadridNavigationBar() {
        // The title is set to empty to disable
        // the label in the back button in the Madrid views.
        self.viewController.title = ""
    }
}

// MARK: Title
private extension OneNavigationBarBuilder {
    func buildTitle() {
        guard let titleKey = self.titleKey else { return }
        self.viewController.navigationItem.titleView = TitleView(
            TitleViewModel(
                style: self.style,
                titleKey: titleKey,
                titleImage: self.oneNavigationBarTitleImage,
                titleConfiguration: self.titleConfiguration,
                tooltipAction: self.tooltipAction,
                tooltipAccessibilityLabelKey: self.tooltipAccessibilityLabelKey,
                accessibilityLabelKey: self.accessibilityTitleLabelKey ?? titleKey,
                accessibilityValue: self.accessibilityTitleValue,
                accessibilityHint: self.accessibilityTitleHint
            )
        )
    }
}

// MARK: Bar tint color
private extension OneNavigationBarBuilder {
    func setBarTintColor() {
        if self.style.isTransparent {
            self.setClearBarTintColor()
        } else {
            self.setBarTintColor(self.style.barTintColor)
        }
    }
    
    func setBarTintColor(_ color: UIColor) {
        self.viewController.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.viewController.navigationController?.navigationBar.shadowImage = UIImage()
        self.viewController.navigationController?.navigationBar.isTranslucent = false
        self.viewController.navigationController?.navigationBar.setNavigationBarColor(color)
    }
    
    func setClearBarTintColor() {
        self.viewController.navigationController?.isNavigationBarHidden = false
        self.viewController.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.viewController.navigationController?.navigationBar.shadowImage = UIImage()
        self.viewController.navigationController?.navigationBar.isTranslucent = true
    }
}
