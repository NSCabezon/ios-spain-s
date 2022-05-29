//
//  OnboardingGPSelectionViewModel.swift
//  Commons
//
//  Created by José Norberto Hidalgo Romero on 13/12/21.
//

import UI
import Foundation
import Localization
import CoreFoundationLib
import OpenCombine
import CoreDomain
import RxSwift

final class OnboardingGPSelectionViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: OnboardingGPSelectionDependenciesResolver
    private let stateSubject = CurrentValueSubject<OnboardingGPSelectionState, Never>(.idle)
    private var currentUserInfo: OnboardingUserInfoRepresentable?
    private lazy var getUserInfoUseCase: GetUserInfoUseCase = dependencies.resolve()
    private lazy var updateUserInfoUseCase: UpdateUserPreferencesUseCase = dependencies.resolve()
    private lazy var getStepperValuesUseCase: GetStepperValuesUseCase = dependencies.resolve()
    var state: AnyPublisher<OnboardingGPSelectionState, Never>
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    init(dependencies: OnboardingGPSelectionDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {        
        suscribeGetUserInfo()
    }
    
    func viewWillAppear() {
        fetchStepperValues()
        trackerManager.trackScreen(screenId: trackerPage.page, extraParameters: [:])
    }
    
    func didScrollToNewOption() {
        let eventId = OnboardingPg.Action.swipe.rawValue
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
    }
    
    func didCloseError() {
        stepsCoordinator.next()
    }
    
    func didSelectBack() {
        stepsCoordinator.back()
    }
    
    func didSelectNext(gpSelected: Int, smartStyleSelected: ButtonType?) {
        guard let gpEntitySelected = GlobalPositionOptionEntity(rawValue: gpSelected) else { return }
        if gpHasChanged(gpSelected: gpSelected, smartStyleSelected: smartStyleSelected) {
            updateGP(gpSelected: gpSelected, smartStyleSelected: smartStyleSelected)
        }
        trackerManager.trackEvent(screenId: trackerPage.page,
                                  eventId: OnboardingPg.Action.continueAction.rawValue,
                                  extraParameters: [TrackerDimension.pgType.key: gpEntitySelected.trackName()])
        self.stateSubject.send(.hideLoading(()))
        self.stepsCoordinator.next()
    }
    
    func didAbortOnboarding(confirmed: Bool, deactivate: Bool) {
        guard confirmed else { return }
        let termination = OnboardingTermination(type: .cancelOnboarding(deactivate: deactivate), gpOption: currentUserInfo?.globalPosition)
        onboardingCoordinator?.dataBinding.set(termination)
        onboardingCoordinator?.dismiss()
    }
}

// MARK: - Private
private extension OnboardingGPSelectionViewModel {
    struct UserInfoInput: UpdateUserPreferencesRepresentable {
        let userId: String
        let alias: String?
        let globalPositionOptionSelected: GlobalPositionOptionEntity?
        let pgColorMode: PGColorMode?
        let photoThemeOptionSelected: Int?
        let isPrivateMenuCoachManagerShown: Bool? = nil
    }
    
    func setInfoPager(gpSelected: GlobalPositionOptionEntity, pgColorMode: PGColorMode) {
        let globalPositionOptions = getGlobalPositionOptions(pgColorMode: pgColorMode)
        stateSubject.send(.showInfo(OnboardingGPSelectionStateInfo(info: globalPositionOptions,
                                                                   titleKey: "onboarding_title_choosePg",
                                                                   currentIndex: gpSelected.value(),
                                                                   bannedIndexes: [])))
    }
    
    func getGlobalPositionOptions(pgColorMode: PGColorMode) -> [PageInfo] {
        return [PageInfo(id: GlobalPositionOption.classic.value(),
                         title: localized("onboarding_title_classic"),
                         description: localized("onboarding_text_classic"),
                         imageName: "imgPgClassic"),
                PageInfo(id: GlobalPositionOption.simple.value(),
                         title: localized("onboarding_title_simple"),
                         description: localized("onboarding_text_simple"),
                         imageName: "imgPgSimple"),
                PageInfo(id: GlobalPositionOption.smart.value(),
                         title: localized("onboarding_title_young"),
                         description: localized("onboarding_text_young"),
                         imageName: pgColorMode.imageName(),
                         smartColorMode: pgColorMode,
                         isEditable: true)]
    }
    
    func gpHasChanged(gpSelected: Int, smartStyleSelected: ButtonType?) -> Bool {
        guard let gpSelected = GlobalPositionOptionEntity(rawValue: gpSelected),
              let currentUserInfo = currentUserInfo
        else { return true }
        let gpChanged = currentUserInfo.globalPosition.value() != gpSelected.rawValue
        if gpSelected == .smart {
            let pgColorModeChanged = currentUserInfo.pgColorMode.rawValue != smartStyleSelected?.rawValue ?? 0
            return gpChanged || pgColorModeChanged
        }
        return gpChanged
    }
    
    func updateGP(gpSelected: Int, smartStyleSelected: ButtonType?) {
        guard let currentUserInfo = currentUserInfo,
              let gpSelected = GlobalPositionOptionEntity(rawValue: gpSelected)
        else { return }
        let pgColorMode = PGColorMode(rawValue: smartStyleSelected?.rawValue ?? 0)
        let userInfoInput = UserInfoInput(userId: currentUserInfo.id,
                                          alias: currentUserInfo.alias,
                                          globalPositionOptionSelected: gpSelected,
                                          pgColorMode: pgColorMode,
                                          photoThemeOptionSelected: currentUserInfo.photoTheme)
        updateUserInfoUseCase.updatePreferences(update: userInfoInput)
    }
    
    func handleStepperValues(_ stepperValues: OnboardingStepperValuesRepresentable) {
        guard let currentPosition = stepperValues.currentPosition else {
            stateSubject.send(.navigationItems(OnboardingGPSelectionStateNavigationItems(allowAbort: configuration.allowAbort,
                                                                                     currentPosition: nil,
                                                                                     total: stepperValues.totalSteps)))
            return
        }
        stateSubject.send(.navigationItems(OnboardingGPSelectionStateNavigationItems(allowAbort: configuration.allowAbort,
                                                                                 currentPosition: currentPosition,
                                                                                 total: stepperValues.totalSteps)))
    }
}

// MARK: - Dependencies
private extension OnboardingGPSelectionViewModel {
    var languageManager: OnboardingLanguageManagerProtocol {
        return dependencies.resolve()
    }
    
    var configuration: OnboardingConfiguration {
        return dependencies.external.resolve()
    }
    
    var onboardingCoordinator: OnboardingCoordinator? {
        return dependencies.resolve()
    }
    
    var stepsCoordinator: StepsCoordinator<OnboardingStep> {
        return dependencies.resolve()
    }
}

// MARK: Subscriptions
private extension OnboardingGPSelectionViewModel {
    func suscribeGetUserInfo() {
        getUserInfoUseCase
            .fetch()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] value in
                self?.currentUserInfo = value
                self?.setInfoPager(gpSelected: value.globalPosition, pgColorMode: value.pgColorMode)
            }).store(in: &anySubscriptions)
    }
    
    func suscribeLanguageManager() {
        languageManager.didLanguageUpdate
            .sink { [weak self] _ in
                guard let self = self, let currentUserInfo = self.currentUserInfo else { return }
                self.setInfoPager(gpSelected: currentUserInfo.globalPosition, pgColorMode: currentUserInfo.pgColorMode)
            }
            .store(in: &anySubscriptions)
    }
    
    func fetchStepperValues() {
        getStepperValuesUseCase.fetch()
            .sink { [unowned self] stepperValues in
                self.handleStepperValues(stepperValues)
            }
            .store(in: &anySubscriptions)
     }
}

// MARK: - Analytics
extension OnboardingGPSelectionViewModel: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: OnboardingPg {
        OnboardingPg()
    }
}
