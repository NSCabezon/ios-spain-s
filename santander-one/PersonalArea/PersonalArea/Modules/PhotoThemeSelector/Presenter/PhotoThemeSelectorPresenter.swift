import CoreFoundationLib
import UI

protocol PhotoThemeSelectorPresenterProtocol {
    var view: PhotoThemeSelectorViewProtocol? { get set }
    var dataManager: PersonalAreaDataManagerProtocol? { get set }
    var moduleCoordinator: PhotoThemeSelectorCoordinator? { get set }
    
    func viewDidLoad()
    func backDidPress()
    func closeDidPress()
    func saveChangesButtonDidPress()
    func currentIndexDidChange(_ index: Int)
    func didAcceptError()
    func didSwipe()
}

final class PhotoThemeSelectorPresenter {
    
    weak var view: PhotoThemeSelectorViewProtocol?
    weak var dataManager: PersonalAreaDataManagerProtocol?
    weak var moduleCoordinator: PhotoThemeSelectorCoordinator?
    private let defaultPhotoThemeOption = 0
    private let resolver: DependenciesResolver
    private lazy var allPhotoTheme: [PageInfo] = {
        self.getAllPhotoTheme()
    }()
    
    init(resolver: DependenciesResolver) {
        self.resolver = resolver
    }
    
    private func setPagerInfo() {
        view?.setInfo(allPhotoTheme,
                      title: nil,
                      bannedIndexes: [])
    }
    
    private func setCurrentPhotoTheme() {
        if let userPref = dataManager?.getUserPreference() {
            view?.setCurrentSelectedTheme(currentIndex: self.getCurrentPhotoThemeIndex(userPref))
        }
    }
}

extension PhotoThemeSelectorPresenter: PhotoThemeSelectorPresenterProtocol {
    func didAcceptError() {
        self.moduleCoordinator?.end()
    }
    
    func viewDidLoad() {
        self.trackScreen()
        self.setPagerInfo()
        self.setCurrentPhotoTheme()
    }
    
    func backDidPress() { moduleCoordinator?.end() }
    func closeDidPress() { moduleCoordinator?.end() }
    
    func saveChangesButtonDidPress() {
        guard let optionSelected = self.view?.getOptionPagerSelected() else {
            return
        }
        guard let theme = self.getPhotoTheme(for: optionSelected) else {
            return
        }
        switch theme {
        case .geographic:
            self.trackEvent(.photoThemeChange, parameters: [.photoType: PersonalAreaPhotoThemePageConstants.geographicPhotoTheme])
        case .pets:
            self.trackEvent(.photoThemeChange, parameters: [.photoType: PersonalAreaPhotoThemePageConstants.petsPhotoTheme])
        case .geometric:
            self.trackEvent(.photoThemeChange, parameters: [.photoType: PersonalAreaPhotoThemePageConstants.geometricPhotoTheme])
        case .architecture:
            self.trackEvent(.photoThemeChange, parameters: [.photoType: PersonalAreaPhotoThemePageConstants.architecturePhotoTheme])
        case .experiences:
            self.trackEvent(.photoThemeChange, parameters: [.photoType: PersonalAreaPhotoThemePageConstants.experiencesPhotoTheme])
        case .nature:
            self.trackEvent(.photoThemeChange, parameters: [.photoType: PersonalAreaPhotoThemePageConstants.naturePhotoTheme])
        case .sports:
            self.trackEvent(.photoThemeChange, parameters: [.photoType: PersonalAreaPhotoThemePageConstants.sportsPhotoTheme])
        case .custom(identifier: _, name: _, trackName: let trackName):
            self.trackEvent(.photoThemeChange, parameters: [.photoType: trackName])
        }
        
        let input: LoadBackgroundImagesUseCaseInput = LoadBackgroundImagesUseCaseInput(theme: theme)
        let useCase: LoadBackgroundImagesUseCase = self.resolver.resolve()
        self.view?.showLoading { [weak self] in
            guard let self = self else {
                return
            }
            UseCaseWrapper(with: useCase.setRequestValues(requestValues: input), useCaseHandler: self.resolver.resolve(), onSuccess: { [weak self] _ in
                self?.view?.dismissLoading { [weak self] in
                    self?.moduleCoordinator?.end()
                }
            }, onError: { [weak self] _ in
                self?.view?.dismissLoading { [weak self] in
                    self?.view?.showError()
                }
            })
        }
    }
    
    func currentIndexDidChange(_ index: Int) {
        if let userPref = dataManager?.getUserPreference() {
            userPref.currentPhotoTheme = index
            dataManager?.updateUserPref(userPref)
        }
    }
    
    func didSwipe() {
        self.trackEvent(.photoThemeSwipe, parameters: [:])
    }
}

extension PhotoThemeSelectorPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return resolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: PersonalAreaConfigurationPhotoThemePGPage {
        return PersonalAreaConfigurationPhotoThemePGPage()
    }
}

private extension PhotoThemeSelectorPresenter {
    
    var additionalPhotoThemeProtocol: PhotoThemeModifierProtocol? {
        return resolver.resolve(forOptionalType: PhotoThemeModifierProtocol.self)
    }
    
    var corePhotoThemeCollection: [PageInfo] {
        return [PageInfo(id: PhotoThemeOptionEntity.geographic.value(), title: localized("onboarding_title_geographic"), description: localized("onboarding_text_geographic"), imageName: "imgGeographicalTheme"),
                PageInfo(id: PhotoThemeOptionEntity.pets.value(), title: localized("onboarding_title_pet"), description: localized("onboarding_text_pet"), imageName: "imgPetsTheme"),
                PageInfo(id: PhotoThemeOptionEntity.geometric.value(), title: localized("onboarding_title_geometic"), description: localized("onboarding_text_geometic"), imageName: "imgGeometryTheme"),
                PageInfo(id: PhotoThemeOptionEntity.architecture.value(), title: localized("onboarding_title_architecture"), description: localized("onboarding_text_architecture"), imageName: "imgArchitectureTheme"),
                PageInfo(id: PhotoThemeOptionEntity.youngs.value(), title: localized("onboarding_title_youngs"), description: localized("onboarding_text_youngs"), imageName: "imgSmartTheme"),
                PageInfo(id: PhotoThemeOptionEntity.nature.value(), title: localized("onboarding_title_nature"), description: localized("onboarding_text_nature"), imageName: "imgNatureTheme"),
                PageInfo(id: PhotoThemeOptionEntity.sports.value(), title: localized("onboarding_title_sport"), description: localized("onboarding_text_sport"), imageName: "imgSportsTheme")]
    }
    
    func getAllPhotoTheme() -> [PageInfo] {
        var photoThemeCollection = corePhotoThemeCollection
        guard let photoThemeProtocol = additionalPhotoThemeProtocol else {
            return photoThemeCollection
        }
        photoThemeCollection.append(contentsOf: photoThemeProtocol.getPhotoThemeInfo())
        return photoThemeCollection
    }
    
    func getPhotoTheme(for optionSelected: Int) -> BackgroundImagesTheme? {
        guard let theme: BackgroundImagesTheme = BackgroundImagesTheme(id: optionSelected) else {
            return additionalPhotoThemeProtocol?.getBackGroundImage(for: optionSelected)
        }
        return theme
    }
    
    func getCurrentPhotoThemeIndex(_ userPref: UserPrefWrapper) -> Int {
        guard let selectedValue = userPref.currentPhotoTheme,
              let photoThemeIndex = (self.allPhotoTheme.find { $0.id == selectedValue }) else {
            return defaultPhotoThemeOption
        }
        return photoThemeIndex
    }
}

fileprivate extension Array {
    func find(_ includedElement: (Element) -> Bool) -> Int? {
        for (idx, element) in enumerated() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}
