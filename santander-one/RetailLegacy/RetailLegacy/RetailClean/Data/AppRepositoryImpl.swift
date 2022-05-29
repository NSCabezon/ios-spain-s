import CoreFoundationLib
import SANLegacyLibrary
import OpenCombine
import Foundation
import CoreDomain

final class AppRepositoryImpl: AppRepository {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    private var persistenceDataSource: PersistenceDataSource
    private var dataRepository: DataRepository
    private var inbentaHostProvider: InbentaHostProvider
    private var publicFilesHostProvider: PublicFilesHostProviderProtocol
    private var sessionAppData: SessionAppData?
    private let dependencies: DependenciesResolver
    private let subject = CurrentValueSubject<Data?, Never>(nil)
    
    init(dependencies: DependenciesResolver,
         persistenceDataSource: PersistenceDataSource,
         dataRepository: DataRepository,
         inbentaHostProvider: InbentaHostProvider,
         publicFilesHostProvider: PublicFilesHostProviderProtocol) {
        self.dependencies = dependencies
        self.persistenceDataSource = persistenceDataSource
        self.dataRepository = dataRepository
        self.inbentaHostProvider = inbentaHostProvider
        self.publicFilesHostProvider = publicFilesHostProvider
        initEnvironments()
    }
    
    private func initEnvironments() {
        if persistenceDataSource.getPublicFilesEnvironmentDTO() == nil, let defaultEnvironment = publicFilesHostProvider.publicFilesEnvironments.first {
            persistenceDataSource.setPublicFilesEnvironmentDTO(publicFilesEnvironmentDTO: defaultEnvironment)
        }
        if persistenceDataSource.getInbentaEnvironmentDTO() == nil, let defaultEnvironment = inbentaHostProvider.inbentaEnvironments.first {
            persistenceDataSource.setInbentaEnvironmentDTO(inbentaEnvironmentDTO: defaultEnvironment)
        }
    }
    
    func isSessionEnabled() -> RepositoryResponse<Bool> {
        return LocalResponse(sessionAppData != nil)
    }
    
    func getPersistedUserAvatar(userId: String) -> RepositoryResponse<Data> {
        return LocalResponse(persistenceDataSource.getPersistedUserAvatar(userId: userId))
    }
    
    func setPersistedUserAvatar(userId: String, image: Data) -> RepositoryResponse<Void> {
        persistenceDataSource.setPersistedUserAvatar(userId: userId, image: image)
        subject.send(image)
        return OkEmptyResponse()
    }
    
    func getPersistedUser() -> RepositoryResponse<PersistedUserDTO> {
        return LocalResponse(persistenceDataSource.getPersistedUser())
    }
    
    func setPersistedUserDTO(persistedUserDTO: PersistedUserDTO) -> RepositoryResponse<Void> {
        persistenceDataSource.setPersistedUser(persistedUser: persistedUserDTO)
        persistenceDataSource.setSharedPersistedUser(persistedUser: persistedUserDTO.sharedPersistedUser)
        return OkEmptyResponse()
    }
    
    func hasPersistedUser() -> RepositoryResponse<Bool> {
        let persistedUser = persistenceDataSource.getPersistedUser()
        if let persistedUser = persistedUser {
            return LocalResponse(checkPersistedUser(persistedUser))
        }
        return LocalResponse(false)
    }
    
    private func checkPersistedUser(_ persistedUser: PersistedUserDTO) -> Bool {
        if let checkerName = self.dependencies.resolve(forOptionalType: AppRepositoryUserPersistedCheckerProtocol.self) {
            return checkerName.checkPersistedUserName(persistedUser)
        } else  if let name = persistedUser.name, !name.isEmpty {
            return !persistedUser.login.isEmpty && !persistedUser.environmentName.isEmpty
        } else {
            return false
        }
    }
    
    func removePersistedUser() -> RepositoryResponse<Void> {
        persistenceDataSource.removePersistedUser()
        persistenceDataSource.removeSharedPersistedUser()
        return OkEmptyResponse()
    }
    
    func getSharedPersistedUser() -> SharedPersistedUserDTOProtocol? {
        return persistenceDataSource.getPersistedUser()?.sharedPersistedUser
    }
    
    func setSharedPersistedUser() -> RepositoryResponse<Void> {
        guard let persistedUserDTO = persistenceDataSource.getPersistedUser() else {
            return LocalResponse(nil)
        }
        persistenceDataSource.setSharedPersistedUser(persistedUser: persistedUserDTO.sharedPersistedUser)
        return OkEmptyResponse()
    }
    
    func isPersistedUserPb() -> RepositoryResponse<Bool> {
        let persistedUser = persistenceDataSource.getPersistedUser()
        if let persistedUser = persistedUser {
            return LocalResponse(persistedUser.isPb)
        }
        return LocalResponse(false)
    }
    
    func getLanguage() -> RepositoryResponse<LanguageType?> {
        return LocalResponse(persistenceDataSource.getPersistedLanguage())
    }
    
    func setLanguage(language: LanguageType) -> RepositoryResponse<Void> {
        persistenceDataSource.setPersistedLanguage(language: language)
        return OkEmptyResponse()
    }
    
    func getTypeDescs() -> RepositoryResponse<[OwnershipTypeDesc]> {
        return LocalResponse(sessionAppData?.currentFilter)
    }
    
    func setTypeDescs(typeDescs: [OwnershipTypeDesc]?) -> RepositoryResponse<Void> {
        sessionAppData?.currentFilter = typeDescs
        return OkEmptyResponse()
    }
    
    func closeSession() -> RepositoryResponse<Void> {
        sessionAppData = nil
        return OkEmptyResponse()
    }
    
    func startSession() -> RepositoryResponse<Void> {
        self.sessionAppData = SessionAppData()
        return OkEmptyResponse()
    }
    
    func getUserPrefDTO(userId: String) -> RepositoryResponse<UserPrefDTO> {
        return LocalResponse(persistenceDataSource.getUserPref(userId: userId))
    }
    
    func setLoginMessages(checkings: [LoginMessagesState: Bool]) -> RepositoryResponse<Void> {
        sessionAppData?.loginMessagesCheckings = checkings
        return OkEmptyResponse()
    }
    
    func getLoginMessagesCheckings() -> RepositoryResponse<[LoginMessagesState: Bool]> {
        return LocalResponse(sessionAppData?.loginMessagesCheckings ?? [:])
    }
    
    func setUserPrefDTO(userPrefDTO: UserPrefDTO) -> RepositoryResponse<Void> {
        persistenceDataSource.setUserPref(userPrefDTO: userPrefDTO)
        return OkEmptyResponse()
    }
    
    func setUserPrefDTOEntity(userPrefDTOEntity: UserPrefDTOEntity) -> RepositoryResponse<Void> {
        persistenceDataSource.setUserPrefEntity(userPrefDTOEntity: userPrefDTOEntity)
        return OkEmptyResponse()
    }
    
    public func getSelectedProduct() -> RepositoryResponse<SelectedProduct> {
        return LocalResponse(sessionAppData?.selectedProduct)
    }
    
    public func setSelectedProduct(selectedProduct: SelectedProduct) -> RepositoryResponse<Void> {
        sessionAppData?.selectedProduct = selectedProduct
        return OkEmptyResponse()
    }
    
    public func setTempLogin(tempLogin: String) -> RepositoryResponse<Void> {
        sessionAppData?.tempLogin = tempLogin
        return OkEmptyResponse()
    }
    
    public func setTempUserType(userType: UserLoginType) -> RepositoryResponse<Void> {
        sessionAppData?.tempUserType = userType
        return OkEmptyResponse()
    }
    
    public func setTempEnvironmentName(tempEnvironmentName: String) -> RepositoryResponse<Void> {
        sessionAppData?.tempEnvironmentName = tempEnvironmentName
        return OkEmptyResponse()
    }
    
    public func setTempName(name: String) -> RepositoryResponse<Void> {
        sessionAppData?.tempName = name
        return OkEmptyResponse()
    }
    
    public func getTempLogin() -> RepositoryResponse<String> {
        return LocalResponse(sessionAppData?.tempLogin)
    }
    
    public func getTempUserType() -> RepositoryResponse<UserLoginType> {
        return LocalResponse(sessionAppData?.tempUserType)
    }
    
    public func getTempEnvironmentName() -> RepositoryResponse<String> {
        return LocalResponse(sessionAppData?.tempEnvironmentName)
    }
    
    public func getTempName() -> RepositoryResponse<String> {
        return LocalResponse(sessionAppData?.tempName)
    }
    
    public func isMixedUser() -> RepositoryResponse<Bool> {
        return LocalResponse(sessionAppData?.isMixedUser)
    }
    
    public func setMixedUsed(isMixedUser: Bool) -> RepositoryResponse<Void> {
        sessionAppData?.isMixedUser = isMixedUser
        return OkEmptyResponse()
    }
    
    func getCommercialSegment() -> RepositoryResponse<CommercialSegmentEntity> {
        return LocalResponse(sessionAppData?.commercialSegment)
    }
    
    func setCommercialSegment(segment: CommercialSegmentEntity) -> RepositoryResponse<Void> {
        sessionAppData?.commercialSegment = segment
        return OkEmptyResponse()
    }
    
    func getTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.tips?.map({ PullOfferTipEntity($0.dto) }) ?? [])
    }
    
    func setTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        sessionAppData?.tips = tips?.map({ PullOffersConfigTip(dto: $0.dto) })
        return OkEmptyResponse()
    }
    
    func getTips() -> RepositoryResponse<[PullOffersConfigTip]?> {
        return LocalResponse(sessionAppData?.tips)
    }
    
    func setTips(tips: [PullOffersConfigTip]?) -> RepositoryResponse<Void> {
        sessionAppData?.tips = tips
        return OkEmptyResponse()
    }
    
    func getSecurityTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.securityTips)
    }
    
    func setSecurityTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        sessionAppData?.securityTips = tips
        return OkEmptyResponse()
    }
    
    func setCardboardingAlmostDoneDebitTips(tips: [PullOfferTipEntity]?) {
        sessionAppData?.cardBoardingAlmostFinishedDebitTips = tips
    }
    
    func setCardboardingAlmostDoneCreditTips(tips: [PullOfferTipEntity]?) {
        sessionAppData?.cardBoardingAlmostFinishedCreditTips = tips
    }
    
    func getSecurityTravelTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.securityTravelTips)
    }
    
    func setSecurityTravelTips(tips: [PullOfferTipEntity]?)-> RepositoryResponse<Void> {
        sessionAppData?.securityTravelTips = tips
        return OkEmptyResponse()
    }
    
    func getHelpCenterTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.helpCenterTips)
    }
    
    func getAtmTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.atmTips)
    }
    
    func getActivateCreditCardTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.activateCreditCardTips)
    }
    
    func getActivateDebitCardTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.activateDebitCardTips)
    }
    func getCardBoardingWelcomeCreditCardTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.cardBoardingWelcomeCreditCardTips)
    }
    
    func getCardBoardingWelcomeDebitCardTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.cardBoardingWelcomeDebitCardTips)
    }
    
    func setHelpCenterTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        sessionAppData?.helpCenterTips = tips
        return OkEmptyResponse()
    }
    
    func setAtmTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        sessionAppData?.atmTips = tips
        return OkEmptyResponse()
    }
    
    func setActivateCreditCardTips(tips: [PullOfferTipEntity]?) {
        sessionAppData?.activateCreditCardTips = tips
    }
    
    func setActivateDebitCardTips(tips: [PullOfferTipEntity]?) {
        sessionAppData?.activateDebitCardTips = tips
    }
    
    func setCardBoardingWelcomeCreditCardTips(tips: [PullOfferTipEntity]?) {
        sessionAppData?.cardBoardingWelcomeCreditCardTips = tips
    }
    
    func setCardBoardingWelcomeDebitCardTips(tips: [PullOfferTipEntity]?) {
        sessionAppData?.cardBoardingWelcomeDebitCardTips = tips
    }
    
    func getSantanderExperiences() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.santanderExperiences)
    }
    
    func getCardboardingAlmostDoneCreditTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.cardBoardingAlmostFinishedCreditTips)
    }
    
    func getCardboardingAlmostDoneDebitTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return LocalResponse(sessionAppData?.cardBoardingAlmostFinishedDebitTips)
    }
    
    func setSantander(experiences: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        sessionAppData?.santanderExperiences = experiences
        return OkEmptyResponse()
    }
    
    public func getPublicFilesEnvironments() -> RepositoryResponse<[PublicFilesEnvironmentDTO]> {
        return LocalResponse(publicFilesHostProvider.publicFilesEnvironments)
    }
    
    public func getInbentaEnvironments() -> RepositoryResponse<[InbentaEnvironmentDTO]> {
        return LocalResponse(inbentaHostProvider.inbentaEnvironments)
    }
    
    public func getCurrentPublicFilesEnvironment() -> RepositoryResponse<PublicFilesEnvironmentDTO> {
        return LocalResponse(persistenceDataSource.getPublicFilesEnvironmentDTO())
    }
    
    public func getCurrentInbentaEnvironment() -> RepositoryResponse<InbentaEnvironmentDTO> {
        return LocalResponse(persistenceDataSource.getInbentaEnvironmentDTO())
    }
    
    public func setPublicEnvironment(publicFilesEnvironmentDTO: PublicFilesEnvironmentDTO) -> RepositoryResponse<Void> {
        persistenceDataSource.setPublicFilesEnvironmentDTO(publicFilesEnvironmentDTO: publicFilesEnvironmentDTO)
        return OkEmptyResponse()
    }
    
    public func setInbentaEnvironment(inbentaEnvironmentDTO: InbentaEnvironmentDTO) -> RepositoryResponse<Void> {
        persistenceDataSource.setInbentaEnvironmentDTO(inbentaEnvironmentDTO: inbentaEnvironmentDTO)
        return OkEmptyResponse()
    }
    
    func isUserPrefPb(userId: String) -> RepositoryResponse<Bool> {
        let userPref = persistenceDataSource.getUserPref(userId: userId)
        return LocalResponse(userPref.isUserPb)
    }
    
    func setUserPrefPb(isPB: Bool, userId: String) -> RepositoryResponse<Void> {
        let userPrefDTO = persistenceDataSource.getUserPref(userId: userId)
        userPrefDTO.isUserPb = isPB
        persistenceDataSource.setUserPref(userPrefDTO: userPrefDTO)
        if let persistedUser = persistenceDataSource.getPersistedUser() {
            persistedUser.isPb = isPB
            persistenceDataSource.setPersistedUser(persistedUser: persistedUser)
        }
        return OkEmptyResponse()
    }
    
    func isCoachmarkShown(coachmarkId: CoachmarkIdentifier, userId: String) -> RepositoryResponse<Bool> {
        return LocalResponse(persistenceDataSource.isCoachmarkShown(userId: userId, coachmarkId: coachmarkId))
    }
    
    func setCoachmarkShown(coachmarkId: [CoachmarkIdentifier], userId: String) -> RepositoryResponse<Void> {
        persistenceDataSource.setCoachmarkShown(userId: userId, coachmarkId: coachmarkId)
        return OkEmptyResponse()
    }
    
    func getCurrentLanguage() -> LanguageType {
        guard let response = try? self.getLanguage().getResponseData(), let languageType = response else {
            let defaultLanguage = self.dependencies.resolve(for: LocalAppConfig.self).language
            let languageList = self.dependencies.resolve(for: LocalAppConfig.self).languageList
            return Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
        }
        
        return languageType
    }
    
    func changeLanguage(language: LanguageType) {
        _ = self.setLanguage(language: language)
    }
    
    private func convertToPGBoxDTOEntity(order: Int, pgBoxDTO: PGBoxDTO) -> PGBoxDTOEntity {
        var productsEntity: [String: PGBoxItemDTOEntity] = [:]
        for product in pgBoxDTO._products {
            productsEntity[product.key] = convertToPGBoxItemDTOEntity(pgBoxItemDTO: product.value)
        }
        return PGBoxDTOEntity(order: order, isOpen: pgBoxDTO.isOpen, products: productsEntity)
    }
    
    private func convertToPGBoxDTO(order: Int, pgBoxDTOEntity: PGBoxDTOEntity) -> PGBoxDTO {
        var productsEntity: [String: PGBoxItemDTO] = [:]
        for product in pgBoxDTOEntity.products {
            productsEntity[product.key] = convertToPGBoxDTOEntity(pGBoxItemDTOEntity: product.value)
        }
        
        return PGBoxDTO(isOpen: pgBoxDTOEntity.isOpen, _products: productsEntity)
    }
    
    private func convertToPGBoxItemDTOEntity(pgBoxItemDTO: PGBoxItemDTO) -> PGBoxItemDTOEntity {
        return PGBoxItemDTOEntity(order: pgBoxItemDTO.order, isVisible: pgBoxItemDTO.isVisible)
    }
    
    private func convertToPGBoxDTOEntity(pGBoxItemDTOEntity: PGBoxItemDTOEntity) -> PGBoxItemDTO {
        return PGBoxItemDTO(order: pGBoxItemDTOEntity.order, isVisible: pGBoxItemDTOEntity.isVisible)
    }
    
    func getSharedUserPreferences(userId: String) -> SharedUserPrefDTOEntity? {
        let sharedUserPref = getUserPreferences(userId: userId).asShared()
        persistenceDataSource.setSharedUserPrefEntity(userPref: sharedUserPref)
        return sharedUserPref
    }
    
    func setSharedUserPref(userId: String) {
        guard persistenceDataSource.isUserPrefEntity(userId: userId) else { return }
        let sharedUserPref = persistenceDataSource.getUserPrefEntity(userId: userId).asShared()
        persistenceDataSource.setSharedUserPrefEntity(userPref: sharedUserPref)
    }
    
    func getUserPreferences(userId: String) -> UserPrefDTOEntity {
        if let userPrefDTOEntity = persistenceDataSource.getIfExistsUserPrefEntity(userId: userId) {
            userPrefDTOEntity.isSmartUser = isSmartUser()
            if let sharedUserPref = persistenceDataSource.getSharedUserPrefEntity(userId: userId),
               userPrefDTOEntity.updateWithSharedUserPref(sharedUserPref) {
                _ = setUserPrefDTOEntity(userPrefDTOEntity: userPrefDTOEntity)
            }
            return userPrefDTOEntity
        } else if let userPrefDTO = try? getUserPrefDTO(userId: userId).getResponseData(),
                  !userPrefDTO.isMigrationSuccess {
            return migrateUserPreferences(userPrefDTO: userPrefDTO)
        } else {
            // This should never happen because of the implementation of self.getUserPrefDTOEntity
            let newUserPref = UserPrefDTOEntity(userId: userId)
            newUserPref.isSmartUser = isSmartUser()
            setUserPreferences(userPref: newUserPref)
            return newUserPref
        }
    }
    
    func setUserPreferences(userPref: UserPrefDTOEntity) {
        //TODO: Remove when stop using userPrefDTO
        if let newUserPref = migrateUserPreferencesToOld(userPrefDTOEntity: userPref) {
            let response = setUserPrefDTO(userPrefDTO: newUserPref)
            if response.isSuccess() {
                _ = setUserPrefDTOEntity(userPrefDTOEntity: userPref)
                persistenceDataSource.setSharedUserPrefEntity(userPref: userPref.asShared())
            }
        }
    }
    
    private func isSmartUser() -> Bool {
        let response = self.getPersistedUser()
        if response.isSuccess(), let responseData = try? response.getResponseData() {
            return responseData.isSmart
        }
        return false
    }
    
    private func migrateUserPreferences(userPrefDTO: UserPrefDTO) -> UserPrefDTOEntity {
        let userPrefDTOEntity = UserPrefDTOEntity(userId: userPrefDTO.userId)
        userPrefDTOEntity.isUserPb = userPrefDTO.isUserPb
        userPrefDTOEntity.isSmartUser = isSmartUser()
        
        userPrefDTOEntity.pgUserPrefDTO.onboardingFinished = userPrefDTO.pgUserPrefDTO.onboardingFinished
        userPrefDTOEntity.pgUserPrefDTO.otpPushBetaFinished = userPrefDTO.pgUserPrefDTO.otpPushBetaFinished
        userPrefDTOEntity.pgUserPrefDTO.globalPositionOptionSelected = userPrefDTO.pgUserPrefDTO.globalPositionOptionSelected
        userPrefDTOEntity.pgUserPrefDTO.photoThemeOptionSelected = userPrefDTO.pgUserPrefDTO.photoThemeOptionSelected
        
        let oldProducts: [ProductTypeEntity: PGBoxDTO] = [
            .account: userPrefDTO.pgUserPrefDTO.accountsBox,
            .card: userPrefDTO.pgUserPrefDTO.cardsBox,
            .loan: userPrefDTO.pgUserPrefDTO.loansBox,
            .deposit: userPrefDTO.pgUserPrefDTO.depositsBox,
            .stockAccount: userPrefDTO.pgUserPrefDTO.stocksBox,
            .fund: userPrefDTO.pgUserPrefDTO.fundssBox,
            .pension: userPrefDTO.pgUserPrefDTO.pensionssBox,
            .managedPortfolio: userPrefDTO.pgUserPrefDTO.portfolioManagedsBox,
            .notManagedPortfolio: userPrefDTO.pgUserPrefDTO.portfolioNotManagedsBox,
            .insuranceSaving: userPrefDTO.pgUserPrefDTO.insuranceSavingsBox,
            .insuranceProtection: userPrefDTO.pgUserPrefDTO.insuranceProtectionsBox
        ]
        
        for (type, defaultOrder) in ProductTypeEntity.getOrderDictionary(isPb: userPrefDTO.isUserPb) {
            guard let oldProduct = oldProducts[type] else { continue }
            userPrefDTOEntity.pgUserPrefDTO.boxes[UserPrefBoxType(type: type)] = convertToPGBoxDTOEntity(order: defaultOrder, pgBoxDTO: oldProduct)
        }
        userPrefDTOEntity.pgUserPrefDTO.resetBoxesConfiguration()
        userPrefDTO.isMigrationSuccess = true
        _ = self.setUserPrefDTO(userPrefDTO: userPrefDTO)
        _ = self.setUserPrefDTOEntity(userPrefDTOEntity: userPrefDTOEntity)
        
        return userPrefDTOEntity
    }
    
    private func migrateUserPreferencesToOld(userPrefDTOEntity: UserPrefDTOEntity) -> UserPrefDTO? {
        
        guard let userPrefDTO = try? self.getUserPrefDTO(userId: userPrefDTOEntity.userId).getResponseData() else {
            return nil
        }
        
        userPrefDTO.isUserPb = userPrefDTOEntity.isUserPb
        
        userPrefDTO.pgUserPrefDTO.onboardingFinished = userPrefDTOEntity.pgUserPrefDTO.onboardingFinished
        userPrefDTO.pgUserPrefDTO.otpPushBetaFinished = userPrefDTOEntity.pgUserPrefDTO.otpPushBetaFinished
        userPrefDTO.pgUserPrefDTO.globalPositionOptionSelected = userPrefDTOEntity.pgUserPrefDTO.globalPositionOptionSelected
        if let photoTheme = userPrefDTOEntity.pgUserPrefDTO.photoThemeOptionSelected { userPrefDTO.pgUserPrefDTO.photoThemeOptionSelected = photoTheme}
        
        userPrefDTOEntity.pgUserPrefDTO.sortedProducts.enumerated().forEach { (product) in
            
            let convertedProduct = convertToPGBoxDTO(order: product.offset, pgBoxDTOEntity: product.element.1)
            if product.element.0 == UserPrefBoxType.account {
                userPrefDTO.pgUserPrefDTO.accountsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.card {
                userPrefDTO.pgUserPrefDTO.cardsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.loan {
                userPrefDTO.pgUserPrefDTO.loansBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.deposit {
                userPrefDTO.pgUserPrefDTO.depositsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.stock {
                userPrefDTO.pgUserPrefDTO.stocksBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.fund {
                userPrefDTO.pgUserPrefDTO.fundssBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.pension {
                userPrefDTO.pgUserPrefDTO.pensionssBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.managedPortfolio {
                userPrefDTO.pgUserPrefDTO.portfolioManagedsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.notManagedPortfolio {
                userPrefDTO.pgUserPrefDTO.portfolioNotManagedsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.insuranceSaving {
                userPrefDTO.pgUserPrefDTO.insuranceSavingsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.insuranceProtection {
                userPrefDTO.pgUserPrefDTO.insuranceProtectionsBox = convertedProduct
            }
        }
        
        return userPrefDTO
    }
    
    func getPersistedUserAvatar(userId: String) -> Data? {
        guard let avatar = try? self.getPersistedUserAvatar(userId: userId).getResponseData() else { return nil }
        return avatar
    }
    
    func setPersistedUserAvatar(userId: String, image: Data) {
        persistenceDataSource.setPersistedUserAvatar(userId: userId, image: image)
        subject.send(image)
    }
    
    func getPendingSolicitudesClosed() -> RepositoryResponse<[PendingSolicitudeEntity]> {
        return LocalResponse(self.sessionAppData?.pendingSolicitudes.closedInGlobalPosition ?? [])
    }
    
    func setPendingSolicitudeClosed(_ pendingSolicitude: PendingSolicitudeEntity) {
        self.sessionAppData?.pendingSolicitudes.closedInGlobalPosition.append(pendingSolicitude)
    }
    
    func getReactiveUserPreferences(userId: String) -> AnyPublisher<UserPrefDTOEntity, Error> {
        return Just(getUserPreferences(userId: userId))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getReactivePersistedUserAvatar(userId: String) -> AnyPublisher<Data?, Never> {
        subject
            .compactMap { image -> Data? in
                return image ?? self.persistenceDataSource.getPersistedUserAvatar(userId: userId)
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    func getReactivePublicFileURL() -> AnyPublisher<URL, Error> {
        guard let environment = persistenceDataSource.getPublicFilesEnvironmentDTO(),
              let stringUrl = environment.urlBase,
              let publicUrl = URL(string: stringUrl) else {
                  return Fail(error: NSError(description: "Invalid url")).eraseToAnyPublisher()
              }
        return Just(publicUrl).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func getPersistedUserAvatarPublisher(userId: String) -> AnyPublisher<Data?, Never> {
        return Just(getPersistedUserAvatar(userId: userId)).eraseToAnyPublisher()
    }
    
    func setReactivePersistedUserAvatar(userId: String, data: Data) -> AnyPublisher<Bool, Never> {
        persistenceDataSource.setPersistedUserAvatar(userId: userId, image: data)
        return Just(true).eraseToAnyPublisher()
    }
}
