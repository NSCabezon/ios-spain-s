//
//  OnboardingPhotoThemePagerPresenter.swift
//  RetailClean
//
//  Created by alvola on 03/10/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//
import CoreFoundationLib

enum PhotoThemeOption: Int {
    case geographic = 0
    case pets
    case geometric
    case architecture
    case youngs
    case nature
    case sports
    
    func value() -> Int {
        return self.rawValue
    }
}

final class OnboardingPhotoThemePagerPresenter: BaseOnboardingPresenter<OnboardingPagerViewController, OnboardingNavigator, OnboardingPresenterProtocol> {
    
    public var dependenciesResolver: DependenciesResolver?
    
    override func loadViewData() {
        super.loadViewData()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadContent),
                                               name: .changedLanguageApp,
                                               object: nil)
        
        self.setInfoPager()
    }
    
    // MARK: - TrackerScreenProtocol
    
    override var screenId: String? {
        return OnboardingPhoto().page
    }
    
    private func setInfoPager() {
        let allPhotoTheme = self.getAllPhotoTheme()
        view.setInfo(allPhotoTheme,
                     title: localized(key: "onboarding_text_chooseSubject"),
                     currentIndex: self.getCurrentPhotoThemeIndex(allPhotoTheme),
                     bannedIndexes: [],
                     isGlobalPosition: false)
    }
}

// MARK: - OnboardingPresenterProtocol methods

extension OnboardingPhotoThemePagerPresenter: OnboardingPresenterProtocol {
    func goBack() {
        navigator.goBack()
    }
    
    func goContinue() {
        let optionSelected: Int = self.view.getOptionPagerSelected()
        guard let theme = self.getBackgroundPhotoTheme(for: optionSelected) else {
            return
        }
        trackEvent(eventId: OnboardingPhoto.Action.continueAction.rawValue, parameters: [TrackerDimension.photoType.key: theme.trackName])
        let input: LoadBackgroundImagesUseCaseInput = LoadBackgroundImagesUseCaseInput(theme: theme)
        let type = LoadingViewType.onScreen(controller: view, completion: { [weak self] in
            guard let self = self else { return }
            UseCaseWrapper(with: self.useCaseProvider.getLoadBackgroundImagesUseCase(input: input), useCaseHandler: self.useCaseHandler, errorHandler: nil, onSuccess: { [weak self] in
                self?.hideAllLoadings(completion: { [weak self] in
                    self?.navigator.next()
                })
                }, onError: { [weak self] _ in
                    self?.hideAllLoadings(completion: { [weak self] in
                        guard let self = self else { return }
                        let acceptComponents = DialogButtonComponents(titled: self.localized(key: "generic_button_understand"), does: { [weak self] in
                            self?.navigator.next()
                        })
                        let titleError = self.stringLoader.getString("onboarding_alert_title_errorImages")
                        let error = self.stringLoader.getString("onboarding_alert_text_errorImages")
                        Dialog.alert(title: titleError, body: error, withAcceptComponent: acceptComponents, withCancelComponent: nil, source: self.view)
                    })
            })
        })
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func scrolledToNewOption() {
        trackEvent(eventId: OnboardingPhoto.Action.swipe.rawValue, parameters: [:])
    }
}

private extension OnboardingPhotoThemePagerPresenter {
    
    var additionalPhotoThemeProtocol: PhotoThemeModifierProtocol? {
        return dependenciesResolver?.resolve(forOptionalType: PhotoThemeModifierProtocol.self)
    }
    
    var corePhotoThemeCollection: [PageInfo] {
        return [PageInfo(id: PhotoThemeOption.geographic.value(), title: localized(key: "onboarding_title_geographic"), description: localized(key: "onboarding_text_geographic"), imageName: "imgGeographicalTheme"),
            PageInfo(id: PhotoThemeOption.pets.value(), title: localized(key: "onboarding_title_pet"), description: localized(key: "onboarding_text_pet"), imageName: "imgPetsTheme"),
            PageInfo(id: PhotoThemeOption.geometric.value(), title: localized(key: "onboarding_title_geometic"), description: localized(key: "onboarding_text_geometic"), imageName: "imgGeometryTheme"),
            PageInfo(id: PhotoThemeOption.architecture.value(), title: localized(key: "onboarding_title_architecture"), description: localized(key: "onboarding_text_architecture"), imageName: "imgArchitectureTheme"),
            PageInfo(id: PhotoThemeOption.youngs.value(), title: localized(key: "onboarding_title_youngs"), description: localized(key: "onboarding_text_youngs"), imageName: "imgSmartTheme"),
            PageInfo(id: PhotoThemeOption.nature.value(), title: localized(key: "onboarding_title_nature"), description: localized(key: "onboarding_text_nature"), imageName: "imgNatureTheme"),
            PageInfo(id: PhotoThemeOption.sports.value(), title: localized(key: "onboarding_title_sport"), description: localized(key: "onboarding_text_sport"), imageName: "imgSportsTheme")]
    }
    
    func getAllPhotoTheme() -> [PageInfo] {
        var photoThemeCollection = corePhotoThemeCollection
        guard let photoThemeProtocol = additionalPhotoThemeProtocol else {
            return photoThemeCollection
        }
        photoThemeCollection.append(contentsOf: photoThemeProtocol.getPhotoThemeInfo())
        return photoThemeCollection
    }
    
    func getCurrentPhotoThemeIndex(_ allPhotoTheme: [PageInfo]) -> Int {
        guard let selectedValue = onboardingUserData?.photoThemeOnboardingSelectedValue,
              let photoThemeIndex = (allPhotoTheme.find{ $0.id == selectedValue }) else {
            return PhotoThemeOption.nature.value()
        }
        return photoThemeIndex
    }
    
    func getBackgroundPhotoTheme(for id: Int) -> BackgroundImagesTheme? {
        guard let theme: BackgroundImagesTheme = BackgroundImagesTheme(id: id) else {
            return additionalPhotoThemeProtocol?.getBackGroundImage(for: id)
        }
        return theme
    }
    
    @objc func reloadContent() {
        self.setInfoPager()
    }
}
