//
//  OnboardingFinalViewModel.swift
//  Onboarding
//
//  Created by José Norberto Hidalgo Romero on 21/12/21.
//

import UI
import Foundation
import Localization
import CoreFoundationLib
import OpenCombine
import CoreDomain
import RxSwift

final class OnboardingFinalViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: OnboardingFinalDependenciesResolver
    private let stateSubject = CurrentValueSubject<OnboardingFinalState, Never>(.idle)
    private var userInfo: OnboardingUserInfoRepresentable?
    private lazy var getUserInfoUseCase: GetUserInfoUseCase = dependencies.resolve()
    private lazy var getDigitalProfilePercentageUseCase: GetDigitalProfilePercentageUseCase = dependencies.external.resolve()
    var state: AnyPublisher<OnboardingFinalState, Never>
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    init(dependencies: OnboardingFinalDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        setNavigationItems()
        fetchUserInfo()
    }
    
    func viewDidAppear() {
        getDigitalProfile()
    }
    
    func viewWillAppear() {
        trackerManager.trackScreen(screenId: trackerPage.page, extraParameters: [:])
    }
    
    func didSelectNext() {
        let termination = OnboardingTermination(type: .onboardingFinished, gpOption: userInfo?.globalPosition)
        onboardingCoordinator?.dataBinding.set(termination)
        onboardingCoordinator?.dismiss()
    }
    
    func didSelectBack() {
        stepsCoordinator.back()
    }
    
    func didPressedContinueDigitalProfile() {
        let termination = OnboardingTermination(type: .digitalProfile, gpOption: userInfo?.globalPosition)
        onboardingCoordinator?.dataBinding.set(termination)
        onboardingCoordinator?.dismiss()
    }
    
    func didAbortOnboarding(confirmed: Bool, deactivate: Bool) {
        guard confirmed else { return }
        let termination = OnboardingTermination(type: .cancelOnboarding(deactivate: deactivate), gpOption: userInfo?.globalPosition)
        onboardingCoordinator?.dataBinding.set(termination)
        onboardingCoordinator?.dismiss()
    }
}

private extension OnboardingFinalViewModel {
    func getDigitalProfile() {
        getDigitalProfilePercentageUseCase
            .fetchIsDigitalProfileEnabled()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] hasDigitalProfile in
                if hasDigitalProfile {
                    self?.getDigitalProfilePercentage()
                }
            })
            .store(in: &anySubscriptions)
    }
    
    func getDigitalProfilePercentage() {
        getDigitalProfilePercentageUseCase
            .fetchDigitalProfilePercentage()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] value in
                self?.stateSubject.send(.digitalProfile(percentage: value))
            })
            .store(in: &anySubscriptions)
    }
    
    func setNavigationItems() {
        stateSubject.send(.navigationItems(OnboardingFinalStateNavigationItems(allowAbort: false,
                                                                               currentPosition: nil,
                                                                               total: nil)))
    }
    
    func fetchUserInfo() {
        getUserInfoUseCase
            .fetch()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] value in
                self?.userInfo = value
            }).store(in: &anySubscriptions)
    }
}

// MARK: - Dependencies
private extension OnboardingFinalViewModel {
    var stepsCoordinator: StepsCoordinator<OnboardingStep> {
        return dependencies.resolve()
    }
    
    var configuration: OnboardingConfiguration {
        return dependencies.external.resolve()
    }
    
    var onboardingCoordinator: OnboardingCoordinator? {
        return dependencies.resolve()
    }
}

// MARK: - Analytics
extension OnboardingFinalViewModel: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: OnboardingFinal {
        OnboardingFinal()
    }
}
