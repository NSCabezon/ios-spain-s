//
//  PersonalAreaHomeViewModel.swift
//  PersonalArea
//
//  Created by alvola on 4/4/22.
//

import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

enum PersonalAreaHomeState: State {
    case idle
    case avatarLoaded(Data)
    case usernameLoaded(String?)
    case homeFieldsLoaded([PersonalAreaCellInfoRepresentable])
}

final class PersonalAreaHomeViewModel {
    private var subscriptions: Set<AnyCancellable> = []
    private let stateSubject = CurrentValueSubject<PersonalAreaHomeState, Never>(.idle)
    var state: AnyPublisher<PersonalAreaHomeState, Never>
    private let persistAvatarSubject = PassthroughSubject<Data, Never>()
    private let refreshAvatarSubject = PassthroughSubject<Void, Never>()
    private let refreshUsernameSubject = PassthroughSubject<Void, Never>()
    private let dependencies: PersonalAreaHomeDependenciesResolver
    
    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().personalArea
    }
    
    private var availableOffers: [(offer: OfferRepresentable, location: PullOfferLocation)] = []
    
    private var coordinator: PersonalAreaHomeCoordinator {
        return self.dependencies.resolve()
    }
    
    init(dependencies: PersonalAreaHomeDependenciesResolver) {
        self.dependencies = dependencies
        self.state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        subscribeToViewConfiguration()
        subscribeToUserAvatar()
        subscribeToUsername()
        subscribeToPersistUserAvatarPublisher()
        trackScreen()
    }
    
    func viewBecomeActive() {
        refreshAvatarSubject.send(())
        refreshUsernameSubject.send(())
    }
    
    func didSelectMenu() {
        coordinator.didSelectMenu()
    }
    
    func didSelectBack() {
        coordinator.dismiss()
    }
    
    func searchAction() {
        coordinator.gotoGlobalSearch()
    }
    
    func didSelect(_ section: PersonalAreaSection) {
        switch section {
        case .digitalProfile:
            trackEvent(.digitalProfile, parameters: [:])
            coordinator.goToDigitalProfile()
        case .configuration:
            trackEvent(.configuration, parameters: [:])
            coordinator.goToConfiguration()
        case .security:
            trackEvent(.security, parameters: [:])
            coordinator.goToSecurity()
        case .documentation:
            trackEvent(.documentation, parameters: [:])
            self.didSelectDocumentation()
        case .recovery:
            self.didSelectRecoveryOffer()
        case .pgPersonalization:
            coordinator.goToPGPersonalization()
        case let .customSection(action):
            coordinator.goToCustomAction(action)
        default:
            break
        }
    }
    
    func didSelectCamera() {
        trackPhoto(PersonaAreaPhotoPage.Action.camera.rawValue)
    }
    
    func didSelectCameraRoll() {
        trackPhoto(PersonaAreaPhotoPage.Action.gallery.rawValue)
    }
    
    func userInfoAction() {
        trackEvent(.name, parameters: [:])
        coordinator.goToUserBasicInfo()
    }
    
    func receivedImageData(_ data: Data) {
        persistAvatarSubject.send(data)
    }
    
    func showError(error: PhotoHelperError) {
        let keyDesc: String
        switch error {
        case .noPermissionCamera:
            keyDesc = "permissionsAlert_text_camera"
        case .noPermissionPhotoLibrary:
            keyDesc = "permissionsAlert_text_photos"
        }
        self.coordinator.openSettings(for: keyDesc)
    }
}

private extension PersonalAreaHomeViewModel {
    var getUserAvatarUseCase: GetUserAvatarUseCase {
        return dependencies.external.resolve()
    }
    
    var getUsernameUseCase: GetUsernameUseCase {
        return dependencies.external.resolve()
    }
    
    var getHomeUserPreferencesUseCase: GetHomeUserPreferencesUseCase {
        return dependencies.external.resolve()
    }
    
    var getCandidateOfferUseCase: GetCandidateOfferUseCase {
        return dependencies.external.resolve()
    }
    
    var getPersonalAreaHomeConfigurationUseCase: GetPersonalAreaHomeConfigurationUseCase {
        return dependencies.external.resolve()
    }
    
    var getDigitalProfileUseCase: GetDigitalProfileUseCase {
        return dependencies.external.resolve()
    }
    
    var getPersonalAreaHomeFieldsUseCase: GetPersonalAreaHomeFieldsUseCase {
        return dependencies.external.resolve()
    }
    
    var persistUserAvatarUseCase: PersistUserAvatarUseCase {
        return dependencies.external.resolve()
    }
}

private extension PersonalAreaHomeViewModel {
    func subscribeToViewConfiguration() {
        Publishers.Zip4(
            sectionsConfigurationPublisher(),
            digitalAreaAndSecurityPublisher(),
            personalDocumentationAndRecoveryEnabledPublisher(),
            digitalProfilePublisher()
        )
            .map(homeEnabledSections)
            .flatMap(getPersonalAreaHomeFieldsPublisher)
            .sink { [unowned self] homeFields in
                self.stateSubject.send(.homeFieldsLoaded(homeFields))
            }
            .store(in: &subscriptions)
    }
    
    func subscribeToUserAvatar() {
        refreshAvatarPublisher()
            .sink { [unowned self] data in
                guard let avatar = data else { return }
                self.stateSubject.send(.avatarLoaded(avatar))
            }
            .store(in: &subscriptions)
    }
    
    func subscribeToUsername() {
        refreshUsernamePublisher()
            .sink { [unowned self] username in
                self.stateSubject.send(.usernameLoaded(username))
            }
            .store(in: &subscriptions)
    }
    
    func subscribeToPersistUserAvatarPublisher() {
        persistUserAvatarPublisher()
            .sink { [unowned self] (success, avatarData) in
                guard success else { return }
                self.stateSubject.send(.avatarLoaded(avatarData))
                NotificationCenter.default.post(name: Notification.Name.didChangeAvatarImage, object: nil)
            }
            .store(in: &subscriptions)
    }
}

private extension PersonalAreaHomeViewModel {
    func sectionsConfigurationPublisher() -> AnyPublisher<PersonalAreaHomeRepresentable, Never> {
        getPersonalAreaHomeConfigurationUseCase
            .fetchPersonalAreaHomeConfiguration()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func userAvatarPublisher() -> AnyPublisher<Data?, Never> {
        getUserAvatarUseCase
            .fetchUserAvatarPublisher()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func usernamePublisher() -> AnyPublisher<String?, Never> {
        getUsernameUseCase
            .fetchUsernamePublisher()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func digitalAreaAndSecurityPublisher() -> AnyPublisher<PersonalAreaDigitalProfileAndSecurityEnable, Never> {
        getHomeUserPreferencesUseCase
            .fetchUserPreferences()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }

    func digitalProfilePublisher() -> AnyPublisher<DigitalProfileRepresentable?, Never> {
        getDigitalProfileUseCase
            .fetchDigitalProfile()
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func personalDocumentationAndRecoveryEnabledPublisher() -> AnyPublisher<PersonalDocAndRecoveryEnabled, Never> {
        let offerPublishers = locations.map(offerPublisherAndLocation)
        return Publishers.MergeMany(offerPublishers)
            .collect()
            .map { [unowned self] offers in
                self.availableOffers = offers.compactMap { $0 }                
                let isPersonalDocOfferEnabled = self.availableOffers.contains { offer in
                    offer.location.stringTag == PersonalAreaPullOffers.personalAreaDocumentary
                }
                let isRecoveryOfferEnabled = self.availableOffers.contains { offer in
                    offer.location.stringTag == PersonalAreaPullOffers.recovery
                }
                return PersonalDocAndRecoveryEnabled(isPersonalDocOfferEnabled: isPersonalDocOfferEnabled,
                                                     isRecoveryOfferEnabled: isRecoveryOfferEnabled)
            }
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func offerPublisher(_ location: PullOfferLocation) -> AnyPublisher<OfferRepresentable?, Never> {
        return getCandidateOfferUseCase
            .fetchCandidateOfferPublisher(location: location)
            .map { $0 }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    func offerPublisherAndLocation(_ location: PullOfferLocation) -> AnyPublisher<(OfferRepresentable, PullOfferLocation)?, Never> {
        return getCandidateOfferUseCase
            .fetchCandidateOfferPublisher(location: location)
            .map { ($0, location) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    func getPersonalAreaHomeFieldsPublisher(_ config: PersonalAreaHomeRepresentable) -> AnyPublisher<[PersonalAreaCellInfoRepresentable], Never> {
        return getPersonalAreaHomeFieldsUseCase
            .fetchPersonalAreaHomeFields(config)
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func persistUserAvatarPublisher() -> AnyPublisher<(Bool, Data), Never> {
        return persistAvatarSubject
            .flatMap { [unowned self] avatarData in
                persistUserAvatarUseCase
                    .persistUserAvatar(avatarData)
                    .map { ($0, avatarData) }
            }
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func refreshAvatarPublisher() -> AnyPublisher<Data?, Never> {
        return refreshAvatarSubject
            .flatMap(userAvatarPublisher)
            .eraseToAnyPublisher()
    }
    
    func refreshUsernamePublisher() -> AnyPublisher<String?, Never> {
        return refreshUsernameSubject
            .flatMap(usernamePublisher)
            .eraseToAnyPublisher()
    }
}

private extension PersonalAreaHomeViewModel {
    func homeEnabledSections(_ countryConfiguration: PersonalAreaHomeRepresentable,
                             _ digitalProfileAndSecurity: PersonalAreaDigitalProfileAndSecurityEnable,
                             _ personalDocAndRecovery: PersonalDocAndRecoveryEnabled,
                             _ digitalProfile: DigitalProfileRepresentable?) -> PersonalAreaHomeRepresentable {
        return PersonalAreaHome(
            isEnabledDigitalProfileView: countryConfiguration.isEnabledDigitalProfileView && digitalProfileAndSecurity.isEnabledDigitalProfileView,
            digitalProfileInfo: PersonalAreaDigitalProfile(digitalProfilePercentage: digitalProfile?.percentage,
                                                           digitalProfileType: digitalProfile?.category),
            isPersonalAreaSecuritySettingEnabled: countryConfiguration.isPersonalAreaSecuritySettingEnabled && digitalProfileAndSecurity.isPersonalAreaSecuritySettingEnabled,
            isPersonalDocOfferEnabled: countryConfiguration.isPersonalDocOfferEnabled && personalDocAndRecovery.isPersonalDocOfferEnabled,
            isRecoveryOfferEnabled: countryConfiguration.isRecoveryOfferEnabled && personalDocAndRecovery.isRecoveryOfferEnabled)
    }
    
    struct PersonalAreaHome: PersonalAreaHomeRepresentable {
        var isEnabledDigitalProfileView: Bool = false
        var digitalProfileInfo: PersonalAreaDigitalProfileRepresentable?
        var isPersonalAreaSecuritySettingEnabled: Bool = false
        var isPersonalDocOfferEnabled: Bool = false
        var isRecoveryOfferEnabled: Bool = false
    }
    
    struct PersonalAreaDigitalProfile: PersonalAreaDigitalProfileRepresentable {
        var digitalProfilePercentage: Double?
        var digitalProfileType: DigitalProfileEnum?
    }
    
    func didSelectDocumentation() {
        if let first = self.availableOffers.first(where: { $0.location.stringTag == PersonalAreaPullOffers.personalAreaDocumentary }) {
            coordinator.goToOffer(first.offer)
        }
    }
    
    func didSelectRecoveryOffer() {
        if let first = self.availableOffers.first(where: { $0.location.stringTag == PersonalAreaPullOffers.recovery }) {
            coordinator.goToOffer(first.offer)
        }
    }
}

extension PersonalAreaHomeViewModel: AutomaticScreenEmmaActionTrackable {
    var trackerManager: TrackerManager {
        return dependencies.external.resolve()
    }
    
    var trackerPage: PersonalAreaPage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependencies.external.resolve()
        let emmaToken = emmaTrackEventList.personalAreaEventID
        return PersonalAreaPage(emmaToken: emmaToken)
    }
    
    func trackPhoto(_ eventId: String) {
        var trackerPagePhoto: PersonaAreaPhotoPage {
            return PersonaAreaPhotoPage()
        }
        self.trackerManager.trackEvent(screenId: trackerPagePhoto.page, eventId: eventId, extraParameters: [:])
    }
}

private struct PersonalDocAndRecoveryEnabled {
    let isPersonalDocOfferEnabled: Bool
    let isRecoveryOfferEnabled: Bool
}
