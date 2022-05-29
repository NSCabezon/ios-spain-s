import Foundation
import CoreFoundationLib

class LocalizationOptionOnboardingViewModel: OnboardingStackItem<LocalizationOptionOnboardingView> {
    // MARK: - Private attributes
    private let stringLoader: StringLoader
    var switchState: Bool
    private let title: String?
    private weak var view: LocalizationOptionOnboardingView?
    private let change: ((LocalizationOptionOnboardingViewModel) -> Void)?
    
    // MARK: - Public methods
    
    init(stringLoader: StringLoader, switchState: Bool, title: String?, change: ((LocalizationOptionOnboardingViewModel) -> Void)?, insets: OnboardingStackViewInsets = OnboardingStackViewInsets(left: 0, right: 0, top: 0, bottom: 24)) {
        self.stringLoader = stringLoader
        self.switchState = switchState
        self.title = title
        self.change = change
        super.init(insets: insets)
    }
    
    override func bind(view: LocalizationOptionOnboardingView) {
        view.setTitleText(stringLoader.getString("onboarding_label_geolocation"))
        view.setDescriptionText(stringLoader.getString("onboarding_text_geolocation"))
        view.setSwitchText(self.titleLocalized)
        view.isSwitchOn = switchState
        view.switchValueDidChange = { [weak self] switchValue in
            self?.switchState = switchValue
            guard let strongSelf = self else { return }
            self?.change?(strongSelf)
        }
        view.setAccesibilityIdentifers("onboarding_label_geolocation")
        self.view = view
    }
    
    func showLoading() {
        view?.loadingView.isHidden = false
        view?.switchButton.isHidden = true
    }
    
    func hideLoading() {
        view?.loadingView.isHidden = true
        view?.switchButton.isHidden = false
    }
}

private extension LocalizationOptionOnboardingViewModel {
    var titleLocalized: LocalizedStylableText {
        if let title = self.title {
            return stringLoader.getString(title)
        } else {
            return self.switchState ? stringLoader.getString("onboarding_label_enabled") : stringLoader.getString("onboarding_label_disabled")
        }
    }
}
