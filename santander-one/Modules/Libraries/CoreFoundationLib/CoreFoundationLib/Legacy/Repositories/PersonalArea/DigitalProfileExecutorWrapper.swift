import SANLegacyLibrary
import CoreDomain

public struct DigitalProfileExecutorWrapperResponse: DigitalProfileRepresentable {
    public let percentage: Double
    public let category: DigitalProfileEnum
    public let configuredItems: [DigitalProfileElemProtocol]
    public let notConfiguredItems: [DigitalProfileElemProtocol]
    public let username: String
    public let userLastname: String
    public let userImage: Data?
}

public struct DigitalProfileExecutorWrapperInput {
    public let globalPosition: GlobalPositionWithUserPrefsRepresentable
    public let provider: BSANManagersProvider
    public let pushNotificationPermissionsManager: PushNotificationPermissionsManagerProtocol?
    public let locationPermissionsManager: LocationPermissionsManagerProtocol?
    public let localAuthPermissionsManager: LocalAuthenticationPermissionsManagerProtocol?
    public let appRepositoryProtocol: AppRepositoryProtocol
    public let appConfigRepository: AppConfigRepositoryProtocol
    public let applePayEnrollmentManager: ApplePayEnrollmentManagerProtocol
    public let dependenciesResolver: DependenciesResolver
    
    public init(globalPosition: GlobalPositionWithUserPrefsRepresentable,
                provider: BSANManagersProvider,
                pushNotificationPermissionsManager: PushNotificationPermissionsManagerProtocol?,
                locationPermissionsManager: LocationPermissionsManagerProtocol?,
                localAuthPermissionsManager: LocalAuthenticationPermissionsManagerProtocol?,
                appRepositoryProtocol: AppRepositoryProtocol,
                appConfigRepository: AppConfigRepositoryProtocol,
                applePayEnrollmentManager: ApplePayEnrollmentManagerProtocol,
                dependenciesResolver: DependenciesResolver) {
        self.globalPosition = globalPosition
        self.provider = provider
        self.pushNotificationPermissionsManager = pushNotificationPermissionsManager
        self.locationPermissionsManager = locationPermissionsManager
        self.localAuthPermissionsManager = localAuthPermissionsManager
        self.appRepositoryProtocol = appRepositoryProtocol
        self.appConfigRepository = appConfigRepository
        self.applePayEnrollmentManager = applePayEnrollmentManager
        self.dependenciesResolver = dependenciesResolver
    }
}

public class DigitalProfileExecutorWrapper {
    private let globalPosition: GlobalPositionWithUserPrefsRepresentable
    private let provider: BSANManagersProvider
    private let pushNotificationPermissionsManager: PushNotificationPermissionsManagerProtocol?
    private let locationPermissionsManager: LocationPermissionsManagerProtocol?
    private let localAuthPermissionsManager: LocalAuthenticationPermissionsManagerProtocol?
    private let appRepositoryProtocol: AppRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let applePayEnrollmentManager: ApplePayEnrollmentManagerProtocol
    private let dependenciesResolver: DependenciesResolver
    
    public init(input: DigitalProfileExecutorWrapperInput) {
        self.globalPosition = input.globalPosition
        self.provider = input.provider
        self.pushNotificationPermissionsManager = input.pushNotificationPermissionsManager
        self.locationPermissionsManager = input.locationPermissionsManager
        self.localAuthPermissionsManager = input.localAuthPermissionsManager
        self.appRepositoryProtocol = input.appRepositoryProtocol
        self.appConfigRepository = input.appConfigRepository
        self.applePayEnrollmentManager = input.applePayEnrollmentManager
        self.dependenciesResolver = input.dependenciesResolver
    }
    
    public func execute() throws -> DigitalProfileExecutorWrapperResponse {// swiftlint:disable:this cyclomatic_complexity
        var configuredItems: [DigitalProfileElemProtocol] = []
        var notConfiguredItems: [DigitalProfileElemProtocol] = []
        var totalPoints: Double = 0
        var usedPoints: Double = 0
        var userImage: Data?
        let userPref = appRepositoryProtocol.getUserPreferences(userId: globalPosition.userId ?? "")
        for element in DigitalProfileElem.allCases {
            var isConfigured: Bool? = false
            var isExcluded: Bool = false
            switch element {
            case .languageSelection, .pgView, .pgCustomization, .pgDirectAccess, .address:
                isConfigured = true
            case .mobilePayment:
                isConfigured = nil
                isExcluded = true
            case .email:
                isConfigured = userPref.pgUserPrefDTO.emailConfigured
            case .phoneNumber:
                isConfigured = userPref.pgUserPrefDTO.phoneConfigured
            case .touchID:
                guard let biometry = localAuthPermissionsManager?.biometryTypeAvailable, biometry.isTouchId else {
                    isConfigured = nil
                    break
                }
                if userPref.pgUserPrefDTO.touchOrFaceIdProfileSaved {
                    isConfigured = true
                } else {
                    isConfigured = localAuthPermissionsManager?.isTouchIdEnabled ?? false
                    self.savePreferences(configured: isConfigured, saved: .touchId)
                }
            case .faceID:
                guard let biometry = localAuthPermissionsManager?.biometryTypeAvailable, biometry.isFaceId else {
                    isConfigured = nil
                    break
                }
                if userPref.pgUserPrefDTO.touchOrFaceIdProfileSaved {
                    isConfigured = true
                } else {
                    isConfigured = localAuthPermissionsManager?.isTouchIdEnabled ?? false
                    self.savePreferences(configured: isConfigured, saved: .touchId)
                }
            case .GDPR:
                isConfigured = nil
                isExcluded = true
            case .geolocalization:
                if userPref.pgUserPrefDTO.geolocalizationProfileSaved {
                    isConfigured = true
                } else {
                    isConfigured = locationPermissionsManager?.isAlreadySet
                    self.savePreferences(configured: isConfigured, saved: .geolocalization)
                }
            case .safeDevice:
                isConfigured = try self.validateDeviceState()
            case .operativity:
                if userPref.pgUserPrefDTO.operativityProfileSaved {
                    isConfigured = true
                } else {
                    isConfigured = try self.checkOperativity()
                    self.savePreferences(configured: isConfigured, saved: .operativity)
                }
            case .notificationPermissions:
                if userPref.pgUserPrefDTO.pushNotificationProfileSaved {
                    isConfigured = true
                } else {
                    guard let manager = pushNotificationPermissionsManager else {
                        isConfigured = false
                        self.savePreferences(configured: isConfigured, saved: .pushNotification)
                        break
                    }
                    manager.isNotificationsEnabled { isNotificationEnabled in
                        isConfigured = isNotificationEnabled
                        self.savePreferences(configured: isConfigured, saved: .pushNotification)
                    }
                }
            case .alias:
                isConfigured = !userPref.pgUserPrefDTO.alias.isEmpty
            case .profilePicture:
                if let userDataDTO = globalPosition.dto?.userDataDTO,
                   let userType = userDataDTO.clientPersonType,
                   let userCode = userDataDTO.clientPersonCode {
                    let userId = userType + userCode
                    userImage = appRepositoryProtocol.getPersistedUserAvatar(userId: userId)
                    isConfigured = userImage != nil
                } else {
                    isConfigured = false
                }
            }
            if let configured = isConfigured {
                let value = Double(element.value())
                totalPoints += value
                if configured {
                    usedPoints += value
                    configuredItems.append(element)
                } else {
                    notConfiguredItems.append(element)
                }
            }
            if isExcluded {
                let value = Double(element.value())
                totalPoints += value
                usedPoints += value
            }
        }
        if let modifier = dependenciesResolver.resolve(forOptionalType: DigitalProfileItemsProviderProtocol.self) {
            let items = modifier.getItems()
            items.configuredItems.forEach { element in
                let value = Double(element.value())
                totalPoints += value
                usedPoints += value
                configuredItems.append(element)
            }
            items.notConfiguredItems.forEach { element in
                let value = Double(element.value())
                totalPoints += value
                notConfiguredItems.append(element)
            }
        }
        let percentage = min(100 * usedPoints/totalPoints, 100)
        let category = DigitalProfileEnum.withPercentage(percentage)
        
        let username: String = globalPosition.clientNameWithoutSurname ?? ""
        let userLastname: String = globalPosition.clientSurname ?? ""
        return DigitalProfileExecutorWrapperResponse(percentage: percentage,
                                                     category: category,
                                                     configuredItems: configuredItems,
                                                     notConfiguredItems: notConfiguredItems,
                                                     username: username,
                                                     userLastname: userLastname,
                                                     userImage: userImage)
    }
}

private extension DigitalProfileExecutorWrapper {
    enum SavedProfileType {
        case pushNotification, touchId, geolocalization, operativity
    }
    
    func savePreferences(configured: Bool?, saved: SavedProfileType) {
        guard let configured = configured, configured == true else { return }
        let userPref = appRepositoryProtocol.getUserPreferences(userId: globalPosition.userId ?? "")
        switch saved {
        case .pushNotification:
            userPref.pgUserPrefDTO.pushNotificationProfileSaved = true
        case .touchId:
            userPref.pgUserPrefDTO.touchOrFaceIdProfileSaved = true
        case .geolocalization:
            userPref.pgUserPrefDTO.geolocalizationProfileSaved = true
        case .operativity:
            userPref.pgUserPrefDTO.operativityProfileSaved = true
            
        }
        appRepositoryProtocol.setUserPreferences(userPref: userPref)
    }
    
    func checkOperativity() throws -> Bool? {
        let response = try provider.getBsanSignatureManager().getCMCSignature()
        if response.isSuccess(), let info = try response.getResponseData(),
           info.signatureDataDTO.list?.first?.userOperabilityInd?.uppercased() == "O" {
            self.savePreferences(configured: true, saved: .operativity)
            return true
        }
        return false
    }
    
    func CMPSStatus() throws -> Bool {
        let response = try provider.getBsanSendMoneyManager().getCMPSStatus()
        if response.isSuccess(),
           let info = try response.getResponseData(),
           info.registeredClientInd == true {
            return true
        } else {
            return false
        }
    }
    
    func validateDeviceState() throws -> Bool {
        let response = try self.provider.getBsanOTPPushManager().getValidatedDeviceState()
        if response.isSuccess(),
           let info = try response.getResponseData() {
            return info == .anotherRegisteredDevice || info == .rightRegisteredDevice
        } else {
            return false
        }
    }
    
    func getMobilePaymentStatus() -> Bool? {
        var isConfigured: Bool?
        if applePayEnrollmentManager.isEnrollingCardEnabled(),
           let enableInAppEnrollment = appConfigRepository.getBool(CardConstants.isInAppEnrollmentEnabled), enableInAppEnrollment {
            guard let enrolledCards = try? provider.getBsanCardsManager().getCardApplePayStatus().getResponseData() else { return false }
            isConfigured = enrolledCards.contains(where: { $0.value.status == .active })
            if isConfigured == false, !getApplePayHasEnrollableCards() {
                isConfigured = nil
            }
        }
        return isConfigured
    }
    
    func getApplePayHasEnrollableCards() -> Bool {
        guard let cards = try? provider.getBsanCardsManager().getAllCards().getResponseData(),
              !cards.isEmpty else { return false }
        return cards.contains(where: {
            self.isCardEnrollable(CardEntity($0))
        })
    }
    
    func isCardEnrollable(_ card: CardEntity) -> Bool {
        guard card.cardType != .prepaid,
              let expirationDate = expirationDateForCard(card),
              let status = try? provider.getBsanCardsManager().getApplePayStatus(for: card.dto,
                                                                                 expirationDate: DateModel(date: expirationDate)),
              let applePayStatus = try? status.getResponseData()
        else { return false }
        return applePayStatus.status != .notEnrollable
    }
    
    func expirationDateForCard(_ card: CardEntity) -> Date? {
        if card.expirationDate != nil {
            let timeManager = dependenciesResolver.resolve(for: TimeManager.self)
            return timeManager.fromString(input: card.expirationDate, inputFormat: .yyyyMM)
        }
        let detailResponse = try? provider.getBsanCardsManager().getCardDetail(cardDTO: card.dto)
        return try? detailResponse?.getResponseData()?.expirationDate
    }
}
