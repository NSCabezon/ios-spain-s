import UIKit
import UI
import CoreFoundationLib

protocol OnboardingOptionsProtocol: OnboardingPresenterProtocol {
    func enterFromBackground()
}

protocol OnboardingOptionsViewProtocol: class {
    func showPromptDialog(info: PromptDialogInfo, identifiers: PromptDialogInfoIdentifiers, closeButtonAvailable: Bool)
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType)
}

final class OnboardingOptionsViewController: BaseViewController<OnboardingOptionsProtocol> {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionsStackView: UIStackView!
    @IBOutlet weak var buttonsView: BottomActionsOnboardingView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shadowView: UIView!

    lazy var dataSource: StackDataSource = { StackDataSource(stackView: optionsStackView, delegate: self) }()
    
    override class var storyboardName: String {
        return "Onboarding"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override func loadView() {
        super.loadView()
        if let bottomButtonsView = BottomActionsOnboardingView.instantiateFromNib() {
            bottomButtonsView.embedInto(container: self.buttonsView)
            self.buttonsView = bottomButtonsView
        }
    }
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = UIColor.uiWhite
                
        titleLabel.applyStyle(LabelStylist(textColor: UIColor.uiBlack, font: UIFont.santanderHeadlineRegular(size: 24), textAlignment: NSTextAlignment.left))
        
        buttonsView.delegate = self
        scrollView.delegate = self
        buttonsView.setupViews()
        configureTexts()
        addNavBarShadow()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollContentView.applyGradientBackground(colorStart: UIColor.uiWhite, colorFinish: UIColor.sky30)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadContent),
                                               name: .changedLanguageApp,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func reloadContent() {
        self.configureTexts()
    }
    
    @objc func appMovedFromBackground() {
        presenter.enterFromBackground()
    }
    
    private func configureTexts() {
        textTitleLabel(localized(key: "onboarding_text_nowOptions"))
        setTitleContinueButton(localized(key: "generic_button_continue"))
        setTitleBackButton(localized(key: "generic_button_previous"))
    }
    
    private func textTitleLabel(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
        titleLabel.set(lineHeightMultiple: 0.85)
    }
    
    private func setTitleContinueButton(_ text: LocalizedStylableText) {
        buttonsView.continueText = text
    }
    
    private func setTitleBackButton(_ text: LocalizedStylableText) {
        buttonsView.backText = text
    }
    
    private func addNavBarShadow() {
        shadowView.drawShadow(offset: (x: 0, y: 0), opacity: 1, color: .coolGray, radius: 0)
    }
    
    var footPrint: String {
        return UIDevice.current.getFootPrint()
    }
    
    var deviceName: String {
        return UIDevice.current.getDeviceName()
    }
    
    func showUnavailableBiometryLoginAlert(_ alert: LocalizedStylableText) {
        TopAlertController.setup(TopAlertView.self).showAlert(alert, alertType: .message)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}

extension OnboardingOptionsViewController: BottomActionsOnboardingViewDelegate {
    func backPressed() {
        presenter.goBack()
    }
    
    func continuePressed() {
        presenter.goContinue()
    }
}

extension OnboardingOptionsViewController: OnboardingClosableProtocol {}

// MARK: - StackDataSourceDelegate
extension OnboardingOptionsViewController: StackDataSourceDelegate {
    func scrollToVisible(view: UIView) {
        scrollView.scrollRectToVisible(view.frame, animated: true)
    }
}

extension OnboardingOptionsViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.layer.shadowRadius = scrollView.contentOffset.y > 0.0 ? 2.0 : 0.0
    }
}

extension OnboardingOptionsViewController: OnboardingOptionsViewProtocol {
    func showPromptDialog(info: PromptDialogInfo, identifiers: PromptDialogInfoIdentifiers, closeButtonAvailable: Bool) {
                let builder = PromptDialogBuilder(info: info,
                                                      identifiers: identifiers)
        LisboaDialog(items: builder.build(),
                     closeButtonAvailable: closeButtonAvailable
        ).showIn(self)
    }
    
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType) {
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: messageType, duration: 4.0)
    }
}

extension OnboardingOptionsViewController: ToolTipBackView {
}

extension OnboardingOptionsViewController: OnBoardingStepView {}
