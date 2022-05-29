//
//  OnboardingChangeAliasViewModel.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 28/12/21.
//

import Foundation
import UI
import OpenCombine
import CoreDomain
import CoreFoundationLib

final class OnboardingChangeAliasViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: OnboardingChangeAliasDependenciesResolver
    private let stateSubject = CurrentValueSubject<OnboardingChangeAliasState, Never>(.idle)
    var state: AnyPublisher<OnboardingChangeAliasState, Never>
    private var userInfo: OnboardingUserInfoRepresentable?
    private var getUserInfoUseCase: GetUserInfoUseCase {
        return dependencies.resolve()
    }
    
    init(dependencies: OnboardingChangeAliasDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    func viewDidLoad() {
        suscribeLanguageManager()
        setNavigationItems()
    }
    
    func viewWillAppear() {
        fetchUserInfo()
    }
    
    func didSelectNext(newAlias: String?) {
        updateAlias(newAlias: newAlias)
        stepsCoordinator.next()
    }
    
    func didSelectBack() {        
        stepsCoordinator.back()
        stepsCoordinator.update(state: .disabled, for: .changeAlias)
    }
    
    func didAbortOnboarding(confirmed: Bool, deactivate: Bool) {
        guard confirmed else { return }
        let termination = OnboardingTermination(type: .cancelOnboarding(deactivate: deactivate), gpOption: userInfo?.globalPosition)
        onboardingCoordinator?.dataBinding.set(termination)
        onboardingCoordinator?.dismiss()
    }
}

// MARK: - Dependencies
private extension OnboardingChangeAliasViewModel {
    var stepsCoordinator: StepsCoordinator<OnboardingStep> {
        return dependencies.resolve()
    }
    
    var updateUserPreferencesUseCase: UpdateUserPreferencesUseCase {
        return dependencies.resolve()
    }
    
    var languageManager: OnboardingLanguageManagerProtocol {
        return dependencies.resolve()
    }
    
    var configuration: OnboardingConfiguration {
        return dependencies.external.resolve()
    }
    
    var onboardingCoordinator: OnboardingCoordinator? {
        return dependencies.resolve()
    }
}

// MARK: - Private
private extension OnboardingChangeAliasViewModel {
    func handleUserInfoCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .failure:
            self.stateSubject.send(.aliasLoaded(""))
        case .finished:
            break
        }
    }
    
    func getAliasToShow(userInfo: OnboardingUserInfoRepresentable) -> String {
        let maxCharacters = 20
        guard let name = (userInfo.alias ?? "").isBlank
                ? userInfo.name.camelCasedString
                : userInfo.alias else {
                    return ""
                }
        return String(name.prefix(maxCharacters))
    }
    
    func updateAlias(newAlias: String?) {
        guard let userInfo = userInfo else { return }
        let alias = newAlias ?? userInfo.name.camelCasedString
        if alias != userInfo.alias {
            let update = Update(userId: userInfo.id, alias: alias)
            updateUserPreferencesUseCase.updatePreferences(update: update)
        }
    }
    
    func setNavigationItems() {
        stateSubject.send(.navigationItems(OnboardingChangeAliasStateNavigationItems(allowAbort: configuration.allowAbort,
                                                                                     currentPosition: nil,
                                                                                     total: nil)))
    }
    
    struct Update: UpdateUserPreferencesRepresentable {
        let userId: String
        let alias: String?
        let globalPositionOptionSelected: GlobalPositionOptionEntity? = nil
        let photoThemeOptionSelected: Int? = nil
        let pgColorMode: PGColorMode? = nil
        let isPrivateMenuCoachManagerShown: Bool? = nil
    }
}

// MARK: Subscriptions
private extension OnboardingChangeAliasViewModel {
    func fetchUserInfo() {
        getUserInfoUseCase.fetch()
            .receive(on: Schedulers.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleUserInfoCompletion(completion: completion)
            },
                  receiveValue: { [weak self] userInfo in
                guard let self = self else { return }
                self.userInfo = userInfo
                self.stateSubject.send(.aliasLoaded(self.getAliasToShow(userInfo: userInfo)))
            })
            .store(in: &anySubscriptions)
    }
    
    func suscribeLanguageManager() {
        languageManager.didLanguageUpdate
            .sink { [weak self] _ in
                guard let self = self, let userInfo = self.userInfo else { return }
                self.stateSubject.send(.aliasLoaded(self.getAliasToShow(userInfo: userInfo)))
                self.setNavigationItems()
            }
            .store(in: &anySubscriptions)
    }
}

// MARK: Analytics
extension OnboardingChangeAliasViewModel: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: OnboardingPage {
        OnboardingPage()
    }
}
