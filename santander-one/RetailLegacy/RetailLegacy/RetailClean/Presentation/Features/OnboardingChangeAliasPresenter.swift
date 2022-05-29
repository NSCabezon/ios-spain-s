import Foundation
import CoreFoundationLib

protocol OnboardingChangeAliasPresenterProtocol: Presenter {
    var userName: String? { get }
    func backButttonPressed()
    func continueButtonPressed(newAlias: String)
    func usernameWithoutAlias() -> String?
}

final class OnboardingChangeAliasPresenter: BaseOnboardingPresenter<OnboardingChangeAliasViewController, OnboardingNavigator, OnboardingChangeAliasPresenterProtocol> {
    private let maxCharacters = 20
    
    override func loadViewData() {
        super.loadViewData()
    }
    
    // MARK: - TrackerScreenProtocol
    
    override var screenId: String? {
        return OnboardingPage().page
    }
}

extension OnboardingChangeAliasPresenter: OnboardingChangeAliasPresenterProtocol {

    var userName: String? {
        guard let name = (onboardingUserData?.userAlias ?? "").isBlank ? onboardingUserData?.userName.camelCasedString : onboardingUserData?.userAlias else {
            return ""
        }
        return String(name.prefix(maxCharacters))
    }
    
    func backButttonPressed() {
        navigator.goBack()
    }
    
    func continueButtonPressed(newAlias: String) {
        guard let onboardingUserData = self.onboardingUserData else { return }
        if newAlias != onboardingUserData.userAlias {
            saveAlias(newAlias)
        }
        navigator.next()
    }
    
    func usernameWithoutAlias() -> String? {
        return onboardingUserData?.userName.camelCasedString
    }
    
    private func saveAlias(_ alias: String) {
        guard let onboardingUserData = self.onboardingUserData else { return }
        let input = UpdateOptionsOnboardingUserPrefUseCaseInput(userId: onboardingUserData.userId,
                                                                onboardingFinished: false,
                                                                globalPositionOptionSelected: nil,
                                                                photoThemeOptionSelected: nil,
                                                                smartColor: nil,
                                                                alias: alias)
        UseCaseWrapper(with: useCaseProvider.getUpdateOptionsOnboardingUserPrefUseCase(input: input),
                       useCaseHandler: useCaseHandler,
                       errorHandler: nil,
                       onSuccess: { _ in
                        onboardingUserData.userAlias = alias
        },
                       onError: nil)
    }
}
