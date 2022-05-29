import Foundation

class PushNotificationsOptionOnboardingViewModel: StackItem<PushNotificationsOptionOnboardingView> {
    // MARK: - Private attributes
    private let stringLoader: StringLoader
    private let userName: String
    var switchState: Bool
    private let title: String?
    private weak var view: PushNotificationsOptionOnboardingView?
    private let change: ((PushNotificationsOptionOnboardingViewModel) -> Void)?
    
    // MARK: - Public methods
    
    init(stringLoader: StringLoader, userName: String, switchState: Bool, title: String?, change: ((PushNotificationsOptionOnboardingViewModel) -> Void)?, insets: Insets = Insets(left: 0, right: 0, top: 0, bottom: 24)) {
        self.stringLoader = stringLoader
        self.userName = userName
        self.switchState = switchState
        self.title = title
        self.change = change
        super.init(insets: insets)
    }
    
    override func bind(view: PushNotificationsOptionOnboardingView) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadContent),
                                               name: .changedLanguageApp,
                                               object: nil)
        
        view.setTitleText(stringLoader.getString("onboarding_label_notifications"))
        view.setDescriptionText(stringLoader.getString("onboarding_text_notifications"))
        view.setSwitchText(self.titleLocalized)
        view.isSwitchOn = switchState
        view.switchValueDidChange = { [weak self] switchValue in
            self?.switchState = switchValue
            guard let strongSelf = self else { return }
            self?.change?(strongSelf)
        }
        view.setAccesibilityIdentifers("onboarding_label_notifications")
        self.view = view
    }
    
    @objc func reloadContent() {
        guard let view = view else { return }
        view.setTitleText(stringLoader.getString("onboarding_label_notifications"))
        view.setDescriptionText(stringLoader.getString("onboarding_text_notifications"))
        view.setSwitchText(self.titleLocalized)
    }
    
    func showLoading() {
        view?.loadingView.isHidden = false
        view?.switchButton.isHidden = true
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.view?.loadingView.isHidden = true
            self?.view?.switchButton.isHidden = false
        }
    }
}

private extension PushNotificationsOptionOnboardingViewModel {
    var titleLocalized: LocalizedStylableText {
        if let title = self.title {
            return stringLoader.getString(title)
        } else {
            return self.switchState ? stringLoader.getString("onboarding_label_enabled") : stringLoader.getString("onboarding_label_disabled")
        }
    }
}
