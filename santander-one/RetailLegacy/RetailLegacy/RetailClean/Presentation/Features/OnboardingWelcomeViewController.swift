import UIKit
import UI

protocol OnboardingWelcomePresenterProtocol: Presenter {
    var getUserName: String? { get }
    func continuePressed()
    func changeAliasPressed()
}

final class OnboardingWelcomeViewController: BaseViewController<OnboardingWelcomePresenterProtocol> {
    
    @IBOutlet weak var welcomeUserLabel: UILabel!
    @IBOutlet weak var welcomeTextLabel: UILabel!
    @IBOutlet weak var areYouReadyLabel: UILabel!
    @IBOutlet weak var changeAliasLabel: UILabel!
    @IBOutlet weak var continueButton: RedLisboaButton!
    @IBOutlet weak var santanderLogo: UIImageView!
    @IBOutlet weak var logoBottomConstraint: NSLayoutConstraint!

    let logoBottonConstraintConstant: CGFloat = 39
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
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = UIColor.white
        continueButton.addSelectorAction(target: self, #selector(buttonTouched))
        santanderLogo.image = Assets.image(named: "icnSanRedComplete")
        welcomeUserLabel.applyStyle(LabelStylist(textColor: UIColor.uiBlack,
                                                 font: UIFont.santanderHeadlineRegular(size: 48),
                                                 textAlignment: .left))
        welcomeTextLabel.applyStyle(LabelStylist(textColor: UIColor.lisboaGrayNew,
                                                 font: UIFont.santanderTextLight(size: 24),
                                                 textAlignment: .left))
        areYouReadyLabel.applyStyle(LabelStylist(textColor: UIColor.lisboaGrayNew,
                                                 font: UIFont.santanderTextBold(size: 24),
                                                 textAlignment: .left))
        self.reloadContent()
    }    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadContent),
                                               name: .changedLanguageApp,
                                               object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabled(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPopGestureEnabled(false)
        reloadContent()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .changedLanguageApp, object: nil)
    }
}

private extension OnboardingWelcomeViewController {
    @objc func reloadContent() {
        self.welcomeTextLabel(localized(key: "onboarding_text_welcome"))
        self.areYouReadyLabel(localized(key: "onboarding_text_ready"))
        self.titleButton(localized(key: "onboarding_button_customize"))
        if let userName = self.presenter.getUserName, !userName.isEmpty {
            self.changeAliasLabel.set(localizedStylableText: localized(key: "onboarding_text_callMeAnotherWay"))
            self.changeAliasLabel.applyStyle(LabelStylist(textColor: UIColor.santanderRed,
                                                     font: UIFont.santanderTextRegular(size: 15),
                                                     textAlignment: .left))
            self.changeAliasLabel.isUserInteractionEnabled = true
            self.changeAliasLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                         action: #selector(changeAliasAction)))
            self.welcomeUserLabel(stringLoader.getString("onboarding_title_hello",
                                                    [StringPlaceholder(StringPlaceholder.Placeholder.name, userName)]))
        } else {
            changeWelcomeLabelConstraints()
        }
    }
    
    @objc func buttonTouched() {
        presenter.continuePressed()
    }
    
    @objc func changeAliasAction() {
        presenter.changeAliasPressed()
    }
    
    func welcomeUserLabel(_ title: LocalizedStylableText) {
        welcomeUserLabel.set(localizedStylableText: title)
        welcomeUserLabel.set(lineHeightMultiple: 0.75)
        welcomeUserLabel.lineBreakMode = .byTruncatingTail
        welcomeUserLabel.numberOfLines = 2
        welcomeUserLabel.adjustsFontSizeToFitWidth = true
        welcomeUserLabel.minimumScaleFactor = 0.1
        welcomeUserLabel.accessibilityIdentifier = AccessibilityOnboarding.helloTitleLabel
    }
    
    func welcomeTextLabel(_ title: LocalizedStylableText) {
        welcomeTextLabel.set(localizedStylableText: title)
        welcomeTextLabel.set(lineHeightMultiple: 0.85)
        welcomeTextLabel.lineBreakMode = .byTruncatingTail
        welcomeTextLabel.minimumScaleFactor = 0.5
        welcomeTextLabel.adjustsFontSizeToFitWidth = true
        welcomeUserLabel.accessibilityIdentifier = AccessibilityOnboarding.welcomeUserLabel
    }
    
    func areYouReadyLabel(_ title: LocalizedStylableText) {
        areYouReadyLabel.set(localizedStylableText: title)
        welcomeTextLabel.minimumScaleFactor = 0.5
        welcomeTextLabel.adjustsFontSizeToFitWidth = true
    }
    
    func titleButton(_ title: LocalizedStylableText) {
        continueButton.set(localizedStylableText: title, state: .normal)
    }
    
    func changeWelcomeLabelConstraints() {
        self.welcomeUserLabel(localized(key: "onboarding_title_welcome"))
        self.changeAliasLabel.constraints.forEach(self.changeAliasLabel.removeConstraint)
        self.welcomeTextLabel.topAnchor.constraint(equalTo: self.welcomeUserLabel.bottomAnchor, constant: 19.0).isActive = true
        self.changeAliasLabel.isHidden = true
        self.logoBottomConstraint.constant = self.logoBottonConstraintConstant
    }
}

extension OnboardingWelcomeViewController: OnboardingClosableProtocol {}

extension OnboardingWelcomeViewController: OnBoardingStepView {}
