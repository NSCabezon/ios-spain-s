import UIKit
import CoreFoundationLib

final class OnboardingLanguagesPresenter: BaseOnboardingPresenter<OnboardingLanguagesViewController, OnboardingNavigator, OnboardingPresenterProtocol> {
    private lazy var sessionDataManager: SessionDataManager = {
        let manager = DefaultSessionDataManager(dependenciesResolver: dependencies.dependenciesEngine)
        manager.setDataManagerProcessDelegate(self)
        return manager
    }()
    private var languageSelected: LanguageType?
    private var items: [ValueOptionType] = []
    
    override func loadViewData() {
        super.loadViewData()
        view.reloadContent()
        reloadLanguages()
    }
    
    private func reloadLanguages() {
        guard let languages = onboardingUserData?.languages else { return }
        for language in languages {
            if language == onboardingUserData?.currentLanguage.languageType {
                languageSelected = language
            }
            let isHighlighted = language == languageSelected
            let option: ValueOptionType = ValueOptionType(value: language.languageName, displayableValue: language.languageName.camelCasedString, localizedValue: localized(key: language.languageName), isHighlighted: isHighlighted, action: { [weak self] in
                self?.setLanguage(language: language)
            })
            items.append(option)
        }
        view.languagesStackView.addValues(items)
    }
    
    private func setLanguage(language: LanguageType) {
        self.languageSelected = language
        view.languagesStackView.reloadValues(self.items, self.languageSelected?.languageName ?? "")
    }
    
    private func reloadFull() {
        let loadingText = LoadingText(title: self.localized(key: "login_popup_loadingPg"), subtitle: self.localized(key: "loading_label_moment"))
        let topInset = 44 + Double(UIScreen.main.statusBarHeight)
        let completion = {
            self.loadPublicFiles()
        }
        let type = LoadingViewType.onDrawer(completion: completion, shakeDelegate: nil)
        let info = LoadingInfo(type: type, loadingText: loadingText, placeholders: nil, topInset: topInset, background: .white)
        showLoading(info: info)
    }
    
    private func loadPublicFiles() {
        dependencies.publicFilesManager.loadPublicFiles(
            addingSubscriptor: OnboardingLanguagesPresenter.self,
            withStrategy: .reload,
            timeout: 5
        ) { [weak self] in
            self?.publicFilesLoadingDidFinish()
        }
    }
    
    private func existsPersistedUser(persistedUser: Bool, error: LoadSessionError) {
        hideLoading(completion: {
            switch error {
            case .generic, .unauthorized, .networkUnavailable, .intern:
                self.view.showGenericErrorDialog(withDependenciesResolver: self.dependencies.navigatorProvider.dependenciesEngine)
            case .other(let errorMessage):
                self.onErrorLoadingPG(LocalizedStylableText(text: errorMessage, styles: nil))
            }
        })
    }
    
    private func onErrorLoadingPG(_ error: LocalizedStylableText) {
        let accept = DialogButtonComponents(titled: localized(key: "generic_button_accept"), does: nil)
        Dialog.alert(title: nil, body: error, withAcceptComponent: accept, withCancelComponent: nil, source: view)
    }
    
    private func handleLoadSessionDataSuccess() {
        NotificationCenter.default.post(name: .changedLanguageApp, object: self)
        sessionManager.sessionStarted { [weak self] in
            guard let strongSelf = self
            else { return }
            strongSelf.navigator.next()
            strongSelf.hideLoading()
            strongSelf.dependencies.publicFilesManager.remove(subscriptor: OnboardingLanguagesPresenter.self)
        }
    }
    
    private func handleLoadSessionError(error: LoadSessionError) {
        NotificationCenter.default.post(name: .changedLanguageApp, object: self)
        UseCaseWrapper(with: useCaseProvider.getCheckPersistedUserUseCase(), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.existsPersistedUser(persistedUser: true, error: error)
            }, onError: { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.existsPersistedUser(persistedUser: false, error: error)
        })
    }
    
    // MARK: - TrackerScreenProtocol
    
    override var screenId: String? {
        return OnboardingLanguage().page
    }
}

extension OnboardingLanguagesPresenter: OnboardingPresenterProtocol {
    func goBack() {
        navigator.goBack()
    }
    
    func goContinue() {
        
        guard let languageSelected = self.languageSelected, languageSelected != onboardingUserData?.currentLanguage.languageType else {
            guard let onboardingUserData = self.onboardingUserData
                else { return }
            trackEvent(eventId: OnboardingLanguage.Action.continueAction.rawValue, parameters: [TrackerDimension.language.key: onboardingUserData.currentLanguage.languageType.rawValue])
            self.navigator.next()
            return
        }
                
        let input = SetLanguageUseCaseInput(language: languageSelected)
        
        trackEvent(eventId: OnboardingLanguage.Action.continueAction.rawValue, parameters: [TrackerDimension.language.key: input.language.rawValue])

        UseCaseWrapper(with: dependencies.useCaseProvider.setLanguageUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            guard let strongSelf = self, let userData = strongSelf.onboardingUserData else { return }
            var onboardingConfiguration = self?.dependencies.dependenciesEngine.resolve(for: OnboardingConfigurationProtocol.self)
            userData.currentLanguage = response.language
            onboardingConfiguration?.userData = userData
            strongSelf.dependencies.localeManager.updateCurrentLanguage(language: response.language)
            strongSelf.reloadFull()
            }
        )
    }
}

extension Notification.Name {
    static let changedLanguageApp = Notification.Name("ChangedLanguageApp")
}

// MARK: - SessionProcessHelperDelegate

extension OnboardingLanguagesPresenter: SessionDataManagerProcessDelegate {
    func handleProcessEvent(_ event: SessionProcessEvent) {
        switch event {
        case .fail(let error):
            handleLoadSessionError(error: error)
        case .loadDataSuccess:
            handleLoadSessionDataSuccess()
        case .updateLoadingMessage:
            break
        case .cancelByUser:
            break
        }
    }
}

// MARK: - PublicFilesSubscriptor

extension OnboardingLanguagesPresenter {
    
    func publicFilesLoadingDidFinish() {
        sessionDataManager.load()
    }
}
