import OpenCombine
import PrivateMenu
import CoreDomain
import CoreFoundationLib

struct ESDisplayManagerPrivateMenuUseCase {
    private let offers: GetCandidateOfferUseCase
    private let privateMenuConfigUseCase: GetPrivateMenuConfigUseCase
    private let userPrefRepository: UserPreferencesRepository
    private let globalPositionRepository: GlobalPositionDataRepository
    private let nameUseCase: GetNameUseCase
    private let personalManagerUseCase: GetPersonalManagerUseCase
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        offers = dependencies.resolve()
        privateMenuConfigUseCase = dependencies.resolve()
        userPrefRepository = dependencies.resolve()
        globalPositionRepository = dependencies.resolve()
        nameUseCase = dependencies.resolve()
        personalManagerUseCase = dependencies.resolve()
    }
}

extension ESDisplayManagerPrivateMenuUseCase: DisplayManagerPrivateMenuUseCase {
    func fetchManagerCoachmarkInfo() -> AnyPublisher<ManagerCoachmarkInfoRepresentable, Never> {
        return Publishers
            .Zip4(showsManager,
                  availableName,
                  managerName,
                  offerRepresentable)
            .zip(thumbnailData)
            .map { representable, data in
                buildInfo(showsManagerCoach: representable.0,
                          title: representable.1,
                          subtitle: representable.2,
                          offerRepresentable: representable.3,
                          thumbnailData: data)
            }
            .eraseToAnyPublisher()
    }
    
    func updateManagerShown(_ isPrivateMenuCoachManagerShown: Bool) -> AnyPublisher<Void, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .map { globalPosition in
                self.updatePreferences(globalPosition.userId,
                                       isPrivateMenuCoachManagerShown: isPrivateMenuCoachManagerShown)
            }
            .eraseToAnyPublisher()
    }
}

private extension ESDisplayManagerPrivateMenuUseCase {
    struct ManagerCoachmarkInfo: ManagerCoachmarkInfoRepresentable {
        let showsManagerCoach: Bool
        var title: LocalizedStylableText? = nil
        var subtitle: LocalizedStylableText? = nil
        var offerRepresentable: OfferRepresentable? = nil
        var thumbnailData: Data? = nil
        
        init(showsManagerCoach: Bool) {
            self.showsManagerCoach = showsManagerCoach
        }
        
        init(showsManagerCoach: Bool,
             title: LocalizedStylableText?,
             subtitle: LocalizedStylableText?,
             offerRepresentable: OfferRepresentable?,
             thumbnailData: Data?) {
            self.showsManagerCoach = showsManagerCoach
            self.title = title
            self.subtitle = subtitle
            self.offerRepresentable = offerRepresentable
            self.thumbnailData = thumbnailData
        }
    }
    
    struct Update: UpdateUserPreferencesRepresentable {
        let userId: String
        let alias: String? = nil
        let globalPositionOptionSelected: GlobalPositionOptionEntity? = nil
        let photoThemeOptionSelected: Int? = nil
        let pgColorMode: PGColorMode? = nil
        let isPrivateMenuCoachManagerShown: Bool?
    }
    
    func buildInfo(showsManagerCoach: Bool,
                   title: LocalizedStylableText?,
                   subtitle: LocalizedStylableText?,
                   offerRepresentable: OfferRepresentable?,
                   thumbnailData: Data?) -> ManagerCoachmarkInfoRepresentable {
        guard showsManagerCoach else { return ManagerCoachmarkInfo(showsManagerCoach: false) }
        return ManagerCoachmarkInfo(showsManagerCoach: showsManagerCoach,
                                    title: title,
                                    subtitle: subtitle,
                                    offerRepresentable: offerRepresentable,
                                    thumbnailData: thumbnailData)
    }
    
    func updatePreferences(_ preferences: UserPreferencesRepresentable,
                           isPrivateMenuCoachManagerShown: Bool) {
        guard preferences.isPrivateMenuCoachManagerShown != isPrivateMenuCoachManagerShown else { return }
        let update = Update(userId: preferences.userId,
                            isPrivateMenuCoachManagerShown: isPrivateMenuCoachManagerShown)
        userPrefRepository.updateUserPreferences(update: update)
    }
    
    func updatePreferences(_ userId: String?, isPrivateMenuCoachManagerShown: Bool) {
        guard let userId = userId else { return }
        let update = Update(userId: userId,
                            isPrivateMenuCoachManagerShown: isPrivateMenuCoachManagerShown)
        userPrefRepository.updateUserPreferences(update: update)
    }
    
    //MARK: - Check if it shows manager
    
    var showsManager: AnyPublisher<Bool, Never> {
        return Publishers
            .Zip3(isPrivateMenuCoachManagerShown,
                  enabledManagerMenu,
                  offerRepresentable)
            .map(checkShowManager)
            .eraseToAnyPublisher()
    }
    
    var isPrivateMenuCoachManagerShown: AnyPublisher<Bool, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .map(\.userId)
            .flatMap { userId -> AnyPublisher<String, Error> in
                guard let userId = userId else { return Fail(error: NSError(description: "no-user-id")).eraseToAnyPublisher() }
                return Just(userId).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .map(userPrefRepository.getUserPreferences)
            .first()
            .flatMap { $0 }
            .filter({userPreferences in
                !userPreferences.isPrivateMenuCoachManagerShown
            })
            .map { userPreferences in
                updatePreferences(userPreferences, isPrivateMenuCoachManagerShown: true)
                return userPreferences.isPrivateMenuCoachManagerShown
            }
            .replaceError(with: true)
            .eraseToAnyPublisher()
    }
    
    var enabledManagerMenu: AnyPublisher<Bool, Never> {
        return privateMenuConfigUseCase
            .fetchPrivateConfigMenuData()
            .map(\.enableManagerMenu)
            .eraseToAnyPublisher()
    }
    
    func checkShowManager(isShown: Bool, enabledManagerMenu: Bool, offer: OfferRepresentable?) -> Bool {
        guard let offer = offer, offer.bannerRepresentable != nil else { return false }
        return !isShown && enabledManagerMenu
    }
    
    //MARK: - Offer
    
    var offerRepresentable: AnyPublisher<OfferRepresentable?, Never> {
        let location = PullOffersLocationsFactoryEntity().privateMenuManager.first
        return getCandidate(location)
    }
    
    func getCandidate( _ location: PullOfferLocationRepresentable?) -> AnyPublisher<OfferRepresentable?, Never> {
        guard let location = location else { return Just(nil).eraseToAnyPublisher() }
        return offers.fetchCandidateOfferPublisher(location: location)
            .flatMap({ offerRepresentable -> AnyPublisher<OfferRepresentable?, Never> in
                return Just(offerRepresentable).eraseToAnyPublisher()
            })
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    //MARK: - Title and Subtitle
    
    func buildTitle(_ name: String?) -> LocalizedStylableText? {
        guard let name = name else { return nil }
        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        let placeholder = [StringPlaceholder(.name, name.camelCasedString)]
        switch hour {
        case 5...13:
            return localized("menu_text_managerGoodMorning", placeholder)
        case 14...19:
            return localized("menu_text_managerGoodAfternoon", placeholder)
        default:
            return localized("menu_text_managerGoodEvening", placeholder)
        }
    }
    
    func buildSubtitle(managerName: String?, offer: OfferRepresentable?) -> LocalizedStylableText? {
        guard let managerName = managerName else { return nil }
        if let productDescription = offer?.productDescription {
            return localized(productDescription)
        } else {
            return localized("menu_text_myManager", [StringPlaceholder(.name, managerName.capitalized)])
        }
    }
    
    var availableName: AnyPublisher<LocalizedStylableText?, Never> {
        return nameUseCase
            .fetchNameOrAlias()
            .map(\.availableName)
            .map(buildTitle)
            .eraseToAnyPublisher()
    }
    
    var managerName: AnyPublisher<LocalizedStylableText?, Never> {
        return personalManagerUseCase
            .fetchPersonalManager()
            .map { $0.first?.nameGest }
            .replaceError(with: nil)
            .zip(offerRepresentable) { name, offer in
                buildSubtitle(managerName: name, offer: offer)
            }
            .eraseToAnyPublisher()
    }
    
    var thumbnailData: AnyPublisher<Data?, Never> {
        return personalManagerUseCase
            .fetchPersonalManager()
            .map { $0.first?.thumbnailData }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
