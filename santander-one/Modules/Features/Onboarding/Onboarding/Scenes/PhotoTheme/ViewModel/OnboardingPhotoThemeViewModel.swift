//
//  OnboardingPhotoThemeViewModel.swift
//  Commons
//
//  Created by Jose Camallonga on 15/12/21.
//

import Foundation
import CoreDomain
import CoreFoundationLib
import OpenCombine
import UI

final class OnboardingPhotoThemeViewModel: DataBindable {
    private let dependencies: OnboardingPhotoThemeDependenciesResolver
    private let stateSubject = CurrentValueSubject<OnboardingPhotoThemeState, Never>(.idle)
    private var anySubscriptions: Set<AnyCancellable> = []
    private lazy var getUserInfoUseCase: GetUserInfoUseCase = dependencies.resolve()
    private lazy var loadBackgroundImagesUseCase: LoadBackgroundImagesUseCase = dependencies.resolve()
    private lazy var stepsCoordinator: StepsCoordinator<OnboardingStep> = dependencies.resolve()
    private lazy var getStepperValuesUseCase: GetStepperValuesUseCase = dependencies.resolve()
    private var userInfo: OnboardingUserInfoRepresentable?
    private var pendingError: Error?
    private var optionSelected: Int = 0
    var state: AnyPublisher<OnboardingPhotoThemeState, Never>
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    init(dependencies: OnboardingPhotoThemeDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {        
        fetchUserInfo()
    }
    
    func viewWillAppear() {
        fetchStepperValues()
    }
    
    func didCloseError() {
        stepsCoordinator.next()
    }
    
    func didShowLoading() {
        guard let theme = self.getBackgroundPhotoTheme(for: optionSelected), let userId = userInfo?.id else { return }
        loadBackgroundImagesUseCase
            .execute(userId: userId, current: theme)
            .sink { [weak self] completion in
                guard case let .failure(error) = completion else { return }
                self?.pendingError = error
                self?.stateSubject.send(.hideLoading(()))
            } receiveValue: { [weak self] _ in
                self?.stateSubject.send(.hideLoading(()))
            }.store(in: &anySubscriptions)
    }
    
    func didHideLoading() {
        if pendingError != nil {
            stateSubject.send(.showErrorAlert(OnboardingPhotoThemeAlert(titleKey: "onboarding_alert_title_errorImages",
                                                                        bodyKey: "onboarding_alert_text_errorImages",
                                                                        acceptKey: "generic_button_understand",
                                                                        acceptAction: { [weak self] in
                self?.stepsCoordinator.next()
            })))
            pendingError = nil
        } else {
            stepsCoordinator.next()
        }
    }
    
    func didScrollToNewOption() {
        trackScroll()
    }
    
    func didSelectBack() {
        stepsCoordinator.back()
    }
    
    func didSelectNext(optionSelected: Int) {
        loadBackgroundImages(optionSelected: optionSelected)
    }
    
    func didAbortOnboarding(confirmed: Bool, deactivate: Bool) {
        guard confirmed else { return }
        let termination = OnboardingTermination(type: .cancelOnboarding(deactivate: deactivate), gpOption: userInfo?.globalPosition)
        onboardingCoordinator?.dataBinding.set(termination)
        onboardingCoordinator?.dismiss()
    }
}

// MARK: - Private
private extension OnboardingPhotoThemeViewModel {
    var additionalPhotoThemeProtocol: PhotoThemeModifierProtocol? {
        return dependencies.external.resolve()
    }
    
    var configuration: OnboardingConfiguration {
        return dependencies.external.resolve()
    }
    
    var onboardingCoordinator: OnboardingCoordinator? {
        return dependencies.resolve()
    }
    
    var corePhotoThemeCollection: [PageInfo] {
        return [PageInfo(id: PhotoThemeOption.geographic.value(),
                         title: localized("onboarding_title_geographic"),
                         description: localized("onboarding_text_geographic"),
                         imageName: "imgGeographicalTheme"),
                PageInfo(id: PhotoThemeOption.pets.value(),
                         title: localized("onboarding_title_pet"),
                         description: localized("onboarding_text_pet"),
                         imageName: "imgPetsTheme"),
                PageInfo(id: PhotoThemeOption.geometric.value(),
                         title: localized("onboarding_title_geometic"),
                         description: localized("onboarding_text_geometic"),
                         imageName: "imgGeometryTheme"),
                PageInfo(id: PhotoThemeOption.architecture.value(),
                         title: localized("onboarding_title_architecture"),
                         description: localized("onboarding_text_architecture"),
                         imageName: "imgArchitectureTheme"),
                PageInfo(id: PhotoThemeOption.youngs.value(),
                         title: localized("onboarding_title_youngs"),
                         description: localized("onboarding_text_youngs"),
                         imageName: "imgSmartTheme"),
                PageInfo(id: PhotoThemeOption.nature.value(),
                         title: localized("onboarding_title_nature"),
                         description: localized("onboarding_text_nature"),
                         imageName: "imgNatureTheme"),
                PageInfo(id: PhotoThemeOption.sports.value(),
                         title: localized("onboarding_title_sport"),
                         description: localized("onboarding_text_sport"),
                         imageName: "imgSportsTheme")]
    }
    
    func fetchUserInfo() {
        getUserInfoUseCase
            .fetch()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] value in
                self?.userInfo = value
                self?.setInfoPager(optionSelectedValue: value.photoTheme)
            }).store(in: &anySubscriptions)
    }
    
    func getAllPhotoTheme() -> [PageInfo] {
        var photoThemeCollection = corePhotoThemeCollection
        guard let photoThemeProtocol = additionalPhotoThemeProtocol else {
            return photoThemeCollection
        }
        photoThemeCollection.append(contentsOf: photoThemeProtocol.getPhotoThemeInfo())
        return photoThemeCollection
    }
    
    func getBackgroundPhotoTheme(for id: Int) -> BackgroundImagesTheme? {
        guard let theme: BackgroundImagesTheme = BackgroundImagesTheme(id: id) else {
            return additionalPhotoThemeProtocol?.getBackGroundImage(for: id)
        }
        return theme
    }
    
    func getCurrentPhotoThemeIndex(_ allPhotoTheme: [PageInfo], optionSelectedValue: Int?) -> Int {
        return allPhotoTheme
            .map { $0.id }
            .first(where: { $0 == optionSelectedValue }) ?? PhotoThemeOption.nature.value()
    }
    
    func loadBackgroundImages(optionSelected: Int) {
        guard let theme = self.getBackgroundPhotoTheme(for: optionSelected) else { return }
        trackerManager.trackEvent(screenId: trackerPage.page,
                                  eventId: OnboardingPhoto.Action.continueAction.rawValue,
                                  extraParameters: [TrackerDimension.photoType.key: theme.trackName])
        let loading = OnboardingPhotoThemeStateLoading(titleKey: "generic_popup_loading", subtitleKey: "loading_label_moment")
        stateSubject.send(.showLoading(loading))
        self.optionSelected = optionSelected
    }
    
    func setInfoPager(optionSelectedValue: Int?) {
        let allPhotoTheme = getAllPhotoTheme()
        let currentIndex = getCurrentPhotoThemeIndex(allPhotoTheme, optionSelectedValue: optionSelectedValue)
        stateSubject.send(.info(OnboardingPhotoThemeStateInfo(info: allPhotoTheme,
                                                              titleKey: "onboarding_text_chooseSubject",
                                                              currentIndex: currentIndex,
                                                              bannedIndexes: [])))
    }
    
    func trackScroll() {
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: OnboardingPhoto.Action.swipe.rawValue, extraParameters: [:])
    }
    
    func fetchStepperValues() {
        getStepperValuesUseCase.fetch()
            .sink { [unowned self] stepperValues in
                self.handleStepperValues(stepperValues)
            }
            .store(in: &anySubscriptions)
     }
    
    func handleStepperValues(_ stepperValues: OnboardingStepperValuesRepresentable) {
        guard let currentPosition = stepperValues.currentPosition else {
            stateSubject.send(.navigationItems(OnboardingPhotoThemeStateNavigationItems(allowAbort: configuration.allowAbort,
                                                                                     currentPosition: nil,
                                                                                     total: stepperValues.totalSteps)))
            return
        }
        stateSubject.send(.navigationItems(OnboardingPhotoThemeStateNavigationItems(allowAbort: configuration.allowAbort,
                                                                                 currentPosition: currentPosition,
                                                                                 total: stepperValues.totalSteps)))
    }
}

// MARK: - Analytics
extension OnboardingPhotoThemeViewModel: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: OnboardingPhoto {
        OnboardingPhoto()
    }
}
