import UIKit
import UI
import CoreFoundationLib

protocol ClassicPGHeaderViewProtocol {
    func estimatedHeightRequired() -> CGFloat
    func setUsername(_ username: String, birthDay: Bool)
}

protocol ClassicPGHeaderViewDelegate: AnyObject {
    func usernameDidPress()
    func isEnabledMoreOptions() -> Bool
}

protocol TableViewHeaderScrollObserver {
    func scrolls(_ offset: CGFloat)
}

final class ClassicPGHeaderView: DesignableView, ClassicPGHeaderViewProtocol {
    
    @IBOutlet weak var moreOptionsButton: UIButton!
    @IBOutlet weak var moreOptionsBack: UIView!
    @IBOutlet weak var leftSeparator: UIView?
    @IBOutlet weak var rightSeparator: UIView?
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contextSelectorImage: UIImageView!
    @IBOutlet weak var contextSelectorButton: UIButton!
    @IBOutlet weak var contextSelectorContainerView: UIView!
    @IBOutlet weak var titleContainerView: UIView!
    
    var isOnScreen = false
    var onResize: (() -> Void)?
    var onMoreOptionsPressed: (() -> Void)?
    var regards: LocalizedStylableText?
    var wasAlreadySeen = false
    var contextSelectorModifier: ContextSelectorModifierProtocol?
    weak var delegate: ClassicPGHeaderViewDelegate?

    override internal func commonInit() {
        super.commonInit()
        self.configureLabels()
        self.configureView()
        self.configureImages()
        self.addContentBackground()
        self.setAccessibility(setViewAccessibility: self.setAccessiblity)
        self.setAccessibilityIdentifiers()
    }

    func setDelegate(_ delegate: ClassicPGHeaderViewDelegate?) {
        self.delegate = delegate
    }

    func setContextSelectorModifier(_ contextSelectorModifier: ContextSelectorModifierProtocol?) {
        self.contextSelectorModifier = contextSelectorModifier
    }

    func estimatedHeightRequired() -> CGFloat {
        self.contentStackView?.layoutIfNeeded()
        return self.contentStackView.frame.height + self.moreOptionsButton.frame.height
    }

    func addView(_ view: UIView) {
        self.contentStackView.addArrangedSubview(view)
    }

    func setUsername(_ username: String, birthDay: Bool) {
        let titleKey = birthDay ? "pg_title_happyBirthday" : "pg_title_welcome"
        let isContextSelectorEnabled = self.contextSelectorModifier?.isContextSelectorEnabled ?? false
        configureRegard(titleKey, name: username, isContextSelectorEnabled: isContextSelectorEnabled)
        guard !isContextSelectorEnabled else { return }
        if birthDay { birthDayEnabled() }
    }

    func seenState() {
        guard let regards = self.regards, wasAlreadySeen == true else { return }
        self.titleLabel.font = .santander(family: .headline, size: 20.0)
        self.titleLabel.configureText(withLocalizedString: regards)
    }

    @IBAction func didPressContextSelector(_ sender: UIButton) {
        self.contextSelectorModifier?.pressedContextSelector()
    }

    @IBAction func didPressMoreOptions(_ sender: Any) {
        if delegate?.isEnabledMoreOptions() == true {
            onMoreOptionsPressed?()
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
}

extension ClassicPGHeaderView: TableViewHeaderScrollObserver {
    func scrolls(_ offset: CGFloat) {
        if (self.titleLabel.frame.origin.x + self.titleLabel.frame.height) < offset {
            self.setAlreadySeen()
        }
    }
}

// MARK: - Private Methods

private extension ClassicPGHeaderView {
    private func addContentBackground() {
        let subView = UIView(frame: self.contentStackView?.bounds ?? CGRect.zero)
        subView.backgroundColor = UIColor.white
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentStackView?.insertSubview(subView, at: 0)
    }

    private func configureView() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 0
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.layer.shadowOpacity = 0.3
        self.leftSeparator?.backgroundColor = UIColor.mediumSkyGray
        self.rightSeparator?.backgroundColor = UIColor.mediumSkyGray
        self.moreOptionsBack.backgroundColor = UIColor.skyGray
    }

    private func configureImages() {
        self.contextSelectorImage.image = Assets.image(named: "icnArrowContextSelector")
        self.moreOptionsButton.setImage(Assets.image(named: "icnMoreOption"), for: .normal)
    }

    private func configureLabels() {
        self.titleLabel.font = UIFont.santander(family: .headline, size: 28.0)
        self.setLabelStyle()
    }

    private func setLabelStyle() {
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.lineBreakMode = .byClipping
        self.titleLabel.minimumScaleFactor = 0.1
    }

    private func configureRegard(_ key: String, name: String, isContextSelectorEnabled: Bool) {
        self.regards = localized(key, [StringPlaceholder(StringPlaceholder.Placeholder.name, name)])
        if isContextSelectorEnabled {
            self.configureContextSelector(withName: name)
        }
        guard let regards = self.regards else { return }
        self.titleLabel.configureText(withLocalizedString: regards)
    }

    private func configureContextSelector(withName name: String) {
        let contextName = self.contextSelectorModifier?.contextName?.camelCasedString ?? ""
        let name = (contextName.isBlank ? name : contextName).withMaxSize(20, truncateTail: !contextName.isBlank)
        self.regards = localized("pg_title_welcome", [StringPlaceholder(StringPlaceholder.Placeholder.name, name)])
        let showContextSelector = self.contextSelectorModifier?.showContextSelector ?? false
        self.contextSelectorContainerView.isHidden = !showContextSelector
    }

    private func birthDayEnabled() {
        self.titleLabel.isUserInteractionEnabled = true
        self.titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(usernameDidPress)))
    }

    private func setAlreadySeen() {
        guard !self.wasAlreadySeen else { return }
        self.wasAlreadySeen = true
        self.seenState()
        self.onResize?()
    }
    
    private func setAccessiblity() {
        self.moreOptionsButton.accessibilityLabel = localized("voiceover_moreShortcuts")
    }
    
    private func setAccessibilityIdentifiers() {
        self.contextSelectorButton.accessibilityIdentifier = AccessibilityGlobalPosition.pgBtnContext
        self.moreOptionsButton.accessibilityIdentifier = AccessibilityGlobalPosition.btnMoreOptionsShortcuts
        self.titleLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgTitleWelcome
        self.moreOptionsBack.accessibilityIdentifier = AccessibilityGlobalPosition.btnMoreOptionsShortcutsBack
    }
    
    @objc private func usernameDidPress() {
        self.delegate?.usernameDidPress()
    }
}

extension ClassicPGHeaderView: AccessibilityCapable { }
