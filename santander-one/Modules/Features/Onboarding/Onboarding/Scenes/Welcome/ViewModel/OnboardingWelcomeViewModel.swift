//
//  OnboardingWelcomeViewModel.swift
//  Onboarding
//
//  Created by José Norberto Hidalgo Romero on 3/12/21.
//

import Foundation
import OpenCombine
import CoreDomain
import UI
import CoreFoundationLib

final class OnboardingWelcomeViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: OnboardingWelcomeDependenciesResolver
    private let stateSubject = CurrentValueSubject<OnboardingWelcomeState, Never>(.idle)
    var state: AnyPublisher<OnboardingWelcomeState, Never>
    private var userInfo: OnboardingUserInfoRepresentable?
    private lazy var getUserInfoUseCase: GetUserInfoUseCase = {
        return dependencies.resolve()
    }()
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    init(dependencies: OnboardingWelcomeDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        suscribeLanguageManager()
        setNavigationItems()
        trackScreen()
    }
    
    func viewWillAppear() {
        fetchUserInfo()
    }
    
    func didAbortOnboarding(confirmed: Bool, deactivate: Bool) {
        guard confirmed else { return }
        let termination = OnboardingTermination(type: .cancelOnboarding(deactivate: deactivate), gpOption: userInfo?.globalPosition)
        onboardingCoordinator?.dataBinding.set(termination)
        onboardingCoordinator?.dismiss()
    }
    
    func didSelectNext() {
        stepsCoordinator.update(state: .disabled, for: .changeAlias)
        stepsCoordinator.next()
    }
    
    func didSelectChangeAlias() {
        stepsCoordinator.update(state: .enabled, for: .changeAlias)
        stepsCoordinator.next()
    }
}

private extension OnboardingWelcomeViewModel {
    var stepsCoordinator: StepsCoordinator<OnboardingStep> {
        return dependencies.resolve()
    }
    
    var onboardingCoordinator: OnboardingCoordinator? {
        return dependencies.resolve()
    }
    
    var configuration: OnboardingConfiguration {
        return dependencies.external.resolve()
    }
    
    var languageManager: OnboardingLanguageManagerProtocol {
        return dependencies.resolve()
    }
    
    @objc func reloadContent() {
        guard let userInfo = userInfo else { return }
        sendUserInfo(userInfo)
        setNavigationItems()
    }
    
    func handleUserInfoCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .failure:
            self.stateSubject.send(.userInfoNotLoaded)
        case .finished:
            break
        }
    }
    
    func setNavigationItems() {
        let items = OnboardingWelcomeStateNavigationItems(allowAbort: configuration.allowAbort, currentPosition: nil, total: nil)
        stateSubject.send(.navigationItems(items))
    }
}

// MARK: Subscriptions
private extension OnboardingWelcomeViewModel {
    func fetchUserInfo() {
        getUserInfoUseCase.fetch()
            .receive(on: Schedulers.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleUserInfoCompletion(completion: completion)
            }, receiveValue: { [weak self] userInfo in
                self?.userInfo = userInfo
                self?.dataBinding.set(userInfo)
                self?.sendUserInfo(userInfo)
            })
            .store(in: &anySubscriptions)
    }
    
    func suscribeLanguageManager() {
        languageManager.didLanguageUpdate
            .sink { [weak self] _ in
                self?.reloadContent()
            }
            .store(in: &anySubscriptions)
    }
    
    func sendUserInfo(_ userInfo: OnboardingUserInfoRepresentable) {
        if let alias = userInfo.alias, !alias.isEmpty {
            stateSubject.send(.userInfoLoaded(alias))
        } else if !userInfo.name.isEmpty {
            stateSubject.send(.userInfoLoaded(userInfo.name.camelCasedString))
        } else {
            stateSubject.send(.userInfoNotLoaded)
        }
    }
}

// MARK: Analytics
extension OnboardingWelcomeViewModel: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: OnboardingPage {
        OnboardingPage()
    }
}
