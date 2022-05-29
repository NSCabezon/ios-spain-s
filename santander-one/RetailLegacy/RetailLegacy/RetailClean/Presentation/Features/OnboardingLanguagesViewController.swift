import UIKit
import UI

final class OnboardingLanguagesViewController: BaseViewController<OnboardingPresenterProtocol> {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languagesStackView: LanguageOnboardingStackView!
    @IBOutlet weak var buttonsView: BottomActionsOnboardingView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

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
        scrollView.applyGradientBackground(colorStart: UIColor.uiWhite, colorFinish: UIColor.sky30)
        titleLabel.applyStyle(LabelStylist(textColor: UIColor.uiBlack, font: UIFont.santanderHeadlineRegular(size: 38), textAlignment: NSTextAlignment.left))
        buttonsView.delegate = self
        buttonsView.setupViews()
    }
    
     override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadContent),
                                               name: .changedLanguageApp,
                                               object: nil)
    }
    
    @objc func reloadContent() {
        textTitleLabel(localized(key: "onboarding_title_selectLanguage"))
        setTitleContinueButton(localized(key: "generic_button_continue"))
        setTitleBackButton(localized(key: "generic_button_previous"))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .changedLanguageApp, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.applyGradientBackground(colorStart: UIColor.uiWhite, colorFinish: UIColor.sky30)
    }
    
    func addValues(_ values: [ValueOptionType]) {
        languagesStackView.addValues(values)
    }
    
    func textTitleLabel(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
        titleLabel.set(lineHeightMultiple: 0.85)
    }
    
    func setTitleContinueButton(_ text: LocalizedStylableText) {
        buttonsView.continueText = text
    }
    
    func setTitleBackButton(_ text: LocalizedStylableText) {
        buttonsView.backText = text
    }
}

extension OnboardingLanguagesViewController: BottomActionsOnboardingViewDelegate {
    func backPressed() {
        presenter.goBack()
    }
    
    func continuePressed() {
        presenter.goContinue()
    }
}

extension OnboardingLanguagesViewController: OnboardingClosableProtocol {}

extension OnboardingLanguagesViewController: OnBoardingStepView {}
