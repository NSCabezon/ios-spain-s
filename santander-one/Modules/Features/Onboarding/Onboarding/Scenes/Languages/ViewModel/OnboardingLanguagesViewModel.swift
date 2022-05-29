//
//  OnboardingLanguagesViewModel.swift
//  Onboarding
//
//  Created by Jose Camallonga on 9/12/21.
//

import UI
import Foundation
import Localization
import CoreFoundationLib
import OpenCombine
import CoreDomain
import RxSwift

final class OnboardingLanguagesViewModel: DataBindable {
    private let dependencies: OnboardingLanguagesDependenciesResolver
    private let stateSubject = CurrentValueSubject<OnboardingLanguagesState, Never>(.idle)
    private var anySubscriptions: Set<AnyCancellable> = []
    private var currentLanguage: LanguageType?
    private var languageSelected: LanguageType?
    private var userInfo: OnboardingUserInfoRepresentable?
    private var items: [ValueOptionType] = []
    private var pendingError: Error?
    private lazy var getUserInfoUseCase: GetUserInfoUseCase = dependencies.resolve()
    private lazy var getUserLanguageUseCase: GetUserLanguageUseCase = dependencies.resolve()
    private lazy var getLanguagesUseCase: GetLanguagesUseCase = dependencies.resolve()
    private lazy var loadPublicFilesUseCase: LoadPublicFilesUseCase = dependencies.resolve()
    private lazy var loadSessionDataUseCase: LoadSessionDataUseCase = dependencies.resolve()
    private lazy var setLanguageUseCase: SetLanguageUseCase = dependencies.resolve()
    private lazy var startSessionUseCase: StartSessionUseCase = dependencies.resolve()
    private lazy var languageManager: OnboardingLanguageManagerProtocol = dependencies.resolve()
    private lazy var getStepperValuesUseCase: GetStepperValuesUseCase = dependencies.resolve()
    
    var state: AnyPublisher<OnboardingLanguagesState, Never>
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    init(dependencies: OnboardingLanguagesDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        fetchContent()
    }
    
    func viewWillAppear() {
        fetchStepperValues()
        trackerManager.trackScreen(screenId: trackerPage.page, extraParameters: [:])
    }
    
    func setLanguage(_ language: LanguageType) {
        languageSelected = language
        stateSubject.send(.values(OnboardingLanguagesStateValues(items: items, languageSelected: language)))
    }
    
    func didShowLoading() {
        reloadFull()
    }
    
    func didHideLoading() {
        if let error = pendingError {
            if let loadSessionError = error as? LoadSessionError, case let .other(message) = loadSessionError {
                let common = OnboardingLanguagesStateAlertCommon(bodyKey: message, acceptKey: "generic_button_accept")
                stateSubject.send(.showErrorAlert(.common(common)))
            } else {
                stateSubject.send(.showErrorAlert(.generic(error)))
            }
            pendingError = nil
        } else {
            next()
        }
    }
    
    func didSelectNext() {
        guard let languageSelected = languageSelected, languageSelected != currentLanguage, let userId = userInfo?.id else {
            trackNext()
            next()
            return
        }
        setLanguageUseCase
            .execute(current: languageSelected, userId: userId)
            .sink { [weak self] _ in
                self?.currentLanguage = languageSelected
                self?.stateSubject.send(.showLoading(OnboardingLanguagesStateLoading(titleKey: "login_popup_loadingPg",
                                                                                     subtitleKey: "loading_label_moment")))
            }.store(in: &anySubscriptions)
    }
    
    func didSelectBack() {
        stepsCoordinator.back()
    }
    
    func didAbortOnboarding(confirmed: Bool, deactivate: Bool) {
        guard confirmed else { return }
        let termination = OnboardingTermination(type: .cancelOnboarding(deactivate: deactivate), gpOption: userInfo?.globalPosition)
        onboardingCoordinator?.dataBinding.set(termination)
        onboardingCoordinator?.dismiss()
    }
}

// MARK: - Private
private extension OnboardingLanguagesViewModel {
    func fetchContent() {
        getUserInfoUseCase.fetch()
            .receive(on: Schedulers.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] value in
                self?.fetchLanguageContent(userId: value.id)
                self?.userInfo = value
            })
            .store(in: &anySubscriptions)
    }
    
    func fetchLanguageContent(userId: String) {
        Publishers.Zip(getLanguagesUseCase.fetch(), getUserLanguageUseCase.fetch(userId: userId))
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] value in
                self?.currentLanguage = value.1.languageType
                self?.setItems(languages: value.0, currentLanguage: value.1)
            }).store(in: &anySubscriptions)
    }
    
    func setItems(languages: [LanguageType], currentLanguage: Language) {
        let items = languages.map { [weak self] language in
            ValueOptionType(value: language.languageName,
                            displayableValue: language.languageName.camelCasedString,
                            localizedValue: localized(language.languageName),
                            isHighlighted: language == currentLanguage.languageType,
                            action: { [weak self] in
                self?.setLanguage(language)
            })
        }
        self.items = items
        stateSubject.send(.values(OnboardingLanguagesStateValues(items: items, languageSelected: nil)))
    }
    
    func fetchStepperValues() {
        getStepperValuesUseCase.fetch()
            .sink { [unowned self] stepperValues in
                self.handleStepperValues(stepperValues)
            }
            .store(in: &anySubscriptions)
    }
    
    func next() {
        anySubscriptions.removeAll()
        stepsCoordinator.next()
    }
    
    func reloadContent() {
        fetchContent()
        stateSubject.send(.reloadContent(()))
    }
    
    func reloadFull() {
        loadPublicFilesUseCase.execute()
            .flatMap { [weak self] _ in
                Just(self?.loadSessionDataUseCase.execute())
                    .eraseToAnyPublisher()
            }
            .flatMap { [weak self] _ in
                Just(self?.startSessionUseCase.execute())
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { [weak self] completion in
                guard case let .failure(error) = completion else { return }
                self?.pendingError = error
                self?.stateSubject.send(.hideLoading(()))
            }, receiveValue: { [weak self] _ in
                self?.languageManager.didLanguageUpdate.send(())
                self?.trackNext()
                self?.stateSubject.send(.hideLoading(()))
                self?.reloadContent()
            }).store(in: &anySubscriptions)
    }
    
    func trackNext() {
        let eventId = OnboardingLanguage.Action.continueAction.rawValue
        let parameters = [TrackerDimension.language.key: languageSelected?.rawValue ?? ""]
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: parameters)
    }
    
    func handleStepperValues(_ stepperValues: OnboardingStepperValuesRepresentable) {
        guard let currentPosition = stepperValues.currentPosition else {
            stateSubject.send(.navigationItems(OnboardingLanguagesStateNavigationItems(allowAbort: configuration.allowAbort,
                                                                                       currentPosition: nil,
                                                                                       total: stepperValues.totalSteps)))
            return
        }
        stateSubject.send(.navigationItems(OnboardingLanguagesStateNavigationItems(allowAbort: configuration.allowAbort,
                                                                                   currentPosition: currentPosition,
                                                                                   total: stepperValues.totalSteps)))
    }
}

// MARK: - Dependencies
private extension OnboardingLanguagesViewModel {
    var stepsCoordinator: StepsCoordinator<OnboardingStep> {
        return dependencies.resolve()
    }
    
    private var configuration: OnboardingConfiguration {
        return dependencies.external.resolve()
    }
    
    var onboardingCoordinator: OnboardingCoordinator? {
        return dependencies.resolve()
    }
}

// MARK: - Analytics
extension OnboardingLanguagesViewModel: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: OnboardingLanguage {
        OnboardingLanguage()
    }
}
