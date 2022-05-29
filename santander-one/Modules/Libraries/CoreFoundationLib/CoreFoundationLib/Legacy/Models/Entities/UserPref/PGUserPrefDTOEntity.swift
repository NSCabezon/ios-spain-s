import CoreDomain

public class PGUserPrefDTOEntity: Codable {
    public var boxes: [UserPrefBoxType: PGBoxDTOEntity] = [:]
    public var alias: String = ""
    public var phoneConfigured = false
    public var emailConfigured = false
    public var onboardingCancelled = false
    public var onboardingFinished = false
    public var otpPushBetaFinished = false
    public var onboardingVersion: Int?
    public var globalPositionOptionSelected = 0
    public var photoThemeOptionSelected: Int?
    public var discreteMode: Bool = false
    public var chartMode: Bool = true
    public var pgColorMode: PGColorMode = .red
    public var frequentOperativesKeys: [String]?
    public var currentTrips: [TripEntity]?
    public var budget: Double?
    public var isTripModeVisited = false
    public var isFirstTimeBiometricCredentialActivated = false
    public var askedForBiometricPermissions = false
    public var whatsNewCounter: Int = 0
    public var whatsNewBigBubbleVisibled: Bool = false
    public var lastLogin: LastLoginInfoDTOEntity?
    public var favoriteContacts: [String]?
    public var sortedProducts: [(UserPrefBoxType, PGBoxDTOEntity)] {
        return boxes.sorted { $0.value.order < $1.value.order }
    }
    public var touchOrFaceIdProfileSaved = false
    public var pushNotificationProfileSaved = false
    public var geolocalizationProfileSaved = false
    public var operativityProfileSaved = false
    public var transitiveAppIcon: AppIconEntity?
    public var isPrivateMenuCoachManagerShown = false
    private var frequentOperatives: [PGFrequentOperativeOption]?
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        boxes = try container.decodeIfPresent([UserPrefBoxType: PGBoxDTOEntity].self, forKey: .boxes) ?? [:]
        alias = try container.decodeIfPresent(String.self, forKey: .alias) ?? ""
        phoneConfigured = try container.decodeIfPresent(Bool.self, forKey: .phoneConfigured) ?? false
        emailConfigured = try container.decodeIfPresent(Bool.self, forKey: .emailConfigured) ?? false
        onboardingCancelled = try container.decodeIfPresent(Bool.self, forKey: .onboardingCancelled) ?? false
        onboardingFinished = try container.decodeIfPresent(Bool.self, forKey: .onboardingFinished) ?? false
        otpPushBetaFinished = try container.decodeIfPresent(Bool.self, forKey: .otpPushBetaFinished) ?? false
        globalPositionOptionSelected = try container.decodeIfPresent(Int.self, forKey: .globalPositionOptionSelected) ?? 0
        photoThemeOptionSelected = try container.decodeIfPresent(Int.self, forKey: .photoThemeOptionSelected)
        discreteMode = try container.decodeIfPresent(Bool.self, forKey: .discreteMode) ?? false
        chartMode = try container.decodeIfPresent(Bool.self, forKey: .chartMode) ?? true
        pgColorMode = try container.decodeIfPresent(PGColorMode.self, forKey: .pgColorMode) ?? .red
        currentTrips = try container.decodeIfPresent([TripEntity].self, forKey: .currentTrips)
        budget = try container.decodeIfPresent(Double.self, forKey: .budget)
        isTripModeVisited = try container.decodeIfPresent(Bool.self, forKey: .isTripModeVisited) ?? false
        isFirstTimeBiometricCredentialActivated = try container.decodeIfPresent(Bool.self, forKey: .isFirstTimeBiometricCredentialActivated) ?? false
        askedForBiometricPermissions = try container.decodeIfPresent(Bool.self, forKey: .askedForBiometricPermissions) ?? false
        whatsNewCounter = try container.decodeIfPresent(Int.self, forKey: .whatsNewCounter) ?? 0
        whatsNewBigBubbleVisibled = try container.decodeIfPresent(Bool.self, forKey: .whatsNewBigBubbleVisibled) ?? false
        lastLogin = try container.decodeIfPresent(LastLoginInfoDTOEntity.self, forKey: .lastLogin) ?? LastLoginInfoDTOEntity()
        favoriteContacts = try container.decodeIfPresent([String].self, forKey: .favoriteContacts) ?? [""]
        touchOrFaceIdProfileSaved = try container.decodeIfPresent(Bool.self, forKey: .touchOrFaceIdProfileSaved) ?? false
        pushNotificationProfileSaved = try container.decodeIfPresent(Bool.self, forKey: .pushNotificationProfileSaved) ?? false
        geolocalizationProfileSaved = try container.decodeIfPresent(Bool.self, forKey: .geolocalizationProfileSaved) ?? false
        operativityProfileSaved = try container.decodeIfPresent(Bool.self, forKey: .operativityProfileSaved) ?? false
        transitiveAppIcon = try container.decodeIfPresent(AppIconEntity.self, forKey: .transitiveAppIcon)
        // In older versions, the onboarding version field was of type String, and so it couldn't be parsed as an Int directly.
        if let onboardingVersionAsInt = try? container.decode(Int.self, forKey: .onboardingVersion) {
            onboardingVersion = onboardingVersionAsInt
        } else if let onboardingVersionAsString = try? container.decode(String.self, forKey: .onboardingVersion),
            let onboardingVersionAsInt = Int(onboardingVersionAsString) {
            onboardingVersion = onboardingVersionAsInt
        } else {
            onboardingVersion = 1
        }
        if let frequentOperatives = try? container.decodeIfPresent([String].self, forKey: .frequentOperativesKeys) {
            self.frequentOperativesKeys = frequentOperatives
        } else {
            self.frequentOperatives = try? container.decodeIfPresent([PGFrequentOperativeOption].self, forKey: .frequentOperatives)
            self.frequentOperativesKeys = self.frequentOperatives?.map { return $0.rawValue }
        }
        isPrivateMenuCoachManagerShown = try container.decodeIfPresent(Bool.self, forKey: .isPrivateMenuCoachManagerShown) ?? false
    }
    
    public func resetBoxesConfiguration() {
        for var box in boxes {
            box.value.setIsOpen(box.key == .account || box.key == .card)
            boxes[box.key] = box.value
        }
    }
}

extension PGUserPrefDTOEntity: PGUserPrefRepresentable {
    public var boxesRepresentable: [UserPrefBoxType: PGBoxRepresentable] {
        return boxes
    }
}

// MARK: Codable
extension PGUserPrefDTOEntity {
    enum CodingKeys: String, CodingKey {
        case boxes
        case alias
        case phoneConfigured
        case emailConfigured
        case onboardingCancelled
        case onboardingFinished
        case otpPushBetaFinished
        case onboardingVersion
        case globalPositionOptionSelected
        case photoThemeOptionSelected
        case discreteMode
        case chartMode
        case pgColorMode
        case frequentOperativesKeys
        case frequentOperatives
        case currentTrips
        case budget
        case isTripModeVisited
        case isFirstTimeBiometricCredentialActivated
        case askedForBiometricPermissions
        case whatsNewCounter
        case lastLogin
        case whatsNewBigBubbleVisibled
        case favoriteContacts
        case touchOrFaceIdProfileSaved
        case pushNotificationProfileSaved
        case geolocalizationProfileSaved
        case operativityProfileSaved
        case transitiveAppIcon
        case isPrivateMenuCoachManagerShown
    }
}

public struct PGBoxDTOEntity: Codable {
    public var order: Int
    public var isOpen: Bool
    public var products: [String: PGBoxItemDTOEntity]
    
    var count: Int {
        return products.count
    }
    
    var sortedProducts: [PGBoxItemDTOEntity] {
        return products.values.sorted { $0.order < $1.order }
    }
    
    public init(order: Int) {
        self.order = order
        self.isOpen = true
        self.products = [:]
    }
    
    public init(order: Int, isOpen: Bool, products: [String: PGBoxItemDTOEntity] = [:]) {
        self.order = order
        self.isOpen = isOpen
        self.products = products
    }
    
    mutating public func set(item: PGBoxItemDTOEntity, withIdentifier identifier: String) {
        products[identifier] = item
    }
    
    public func getItem(withIdentifier identifier: String) -> PGBoxItemDTOEntity? {
        return products[identifier]
    }
    
    mutating public func removeAllItems() {
        products = [:]
    }
    
    mutating public func setIsOpen(_ isOpen: Bool) {
        self.isOpen = isOpen
    }
}

extension PGBoxDTOEntity: PGBoxRepresentable {
    public var productsRepresentable: [String: PGBoxItemRepresentable] {
        return products
    }
}

public struct PGBoxItemDTOEntity: Codable {
    public var order: Int
    public var isVisible: Bool
    
    public init(order: Int, isVisible: Bool) {
        self.order = order
        self.isVisible = isVisible
    }
}

extension PGBoxItemDTOEntity: PGBoxItemRepresentable { }
