import CoreDomain

public struct PersonalAreaConstants {
    public static let isPersonalAreaEnabled = "enablePersonalAreaBDP"
    public static let isPersonalAreaSecuritySettingEnabled = "enableSecuritySettingPersonalArea"
}

public struct PersonalAreaPullOffers {
    public static let secureDeviceTutorial = "AREA_PERSONAL_SEGURO"
    public static let personalAreaDocumentary = "PERSONAL_AREA_DOCUMENTARY_MANAGEMENT"
    public static let recovery = "RECOBROS_AREA_PERSONAL"
    public static let contactData = "DATOS_CONTACTO"
    public static let contactDataDNI = "DATOS_CONTACTO_DNI"
    public static let gdpr = "GDPR"
    public static let configAlerts = "AREA_PERSONAL_CONFIG_ALERTAS"
    public static let discreteModeVideo = "AREA_PERSONAL_DISCRETO"
}

// MARK: - Tracker

public struct PersonalAreaConfigPGPageConstants {
    public static let smartPgType = "smrt"
    public static let classicPgType = "clas"
    public static let simplePgType = "sen"
}

public struct PersonalAreaPhotoThemePageConstants {
    public static let geographicPhotoTheme = "geo"
    public static let petsPhotoTheme = "mas"
    public static let geometricPhotoTheme = "for"
    public static let architecturePhotoTheme = "arq"
    public static let experiencesPhotoTheme = "exp"
    public static let naturePhotoTheme = "nat"
    public static let sportsPhotoTheme = "dep"
}

public struct PersonalAreaPage: PageWithActionTrackable, EmmaTrackable {
    public let emmaToken: String
    public typealias ActionType = Action
    public let page = "/personal_area"
    
    public enum Action: String {
        case name = "click_name"
        case digitalProfile = "click_digital_profile"
        case configuration = "click_configuration"
        case security = "click_security"
        case documentation = "click_documentation"
        case photo = "click_photo"
    }
    public init() {
        self.emmaToken = ""
    }
    public init(emmaToken: String) {
        self.emmaToken = emmaToken
    }
}

public struct PersonaAreaPhotoPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/personal_area/photo"
    
    public enum Action: String {
        case gallery = "click_gallery"
        case camera = "click_camera"
    }
    public init() {}
}

public struct PersonalAreaNamePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/personal_area/name"
    
    public enum Action: String {
        case photo = "edit_photo"
        case edit = "edit_alias"
        case save = "save_new_alias"
        case phone = "edit_phone"
        case mail = "edit_email"
        case GDPR = "click_consent"
    }
    public init() {}
}
public struct PersonaAreaNamePhotoPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/personal_area/photo"
    
    public enum Action: String {
        case gallery = "open_gallery"
        case camera = "open_camera"
    }
    public init() {}
}

public struct PersonalAreaConfigurationPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/personal_area/configuration"
    
    public enum Action: String {
        case language = "select_language"
        case pgType = "personalize_gp_type"
        case photo = "click_photo_type"
        case notificationsOn = "unlock_notification"
        case notificationsOff = "lock_notification"
        case appPermissions = "manage_app_permissions"
        case appInfo = "click_app_info"
    }
    public init() {}
}

public struct PersonalAreaConfigurationLanguagePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/personal_area/configuration/language"
    
    public enum Action: String {
        case change = "change_language"
    }
    public init() {}
}

public struct PersonalAreaConfigurationPGPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/personal_area/global_position/configuration"
    
    public enum Action: String {
        case pgSwipe = "swipe_global_posiiton_type"
        case discreteModeOn = "unlock_discrete_mode"
        case discreteModeOff = "lock_discrete_mode"
        case activateGraphics =  "unlock_graph"
        case deactivateGraphics = "lock_graph"
        case financingCharts = "click_budget"
        case frequentOperations = "click_frequent_transactions"
        case products = "click_product"
        case save = "save_setting"
        case saveChanges = "save_changes"

    }
    public init() {}
}

public struct PersonalAreaConfigurationPGProductPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/personal_area/global_position/configuration/product"
    
    public enum Action: String {
        case accountOn = "unlock_account"
        case accountOff = "lock_account"
        case accountEditAlias = "edit_account_alias"
        case accountMove = "move_account"
        case accountSectionMove = "select_account_to_move"
        case cardOn = "unlock_card"
        case cardOff = "lock_card"
        case cardEditAlias = "edit_card_alias"
        case cardMove = "move_card"
        case cardSectionMove = "select_card_to_move"
        case savingProductOn = "unlock_saving_products"
        case savingProductOff = "lock_saving_products"
        case savingProductEditAlias = "edit_saving_products_alias"
        case savingProductMove = "move_saving_products"
        case savingProductSectionMove = "select_saving_products_to_move"
        case stockAccountOn = "unlock_share"
        case stockAccountOff = "lock_share"
        case stockAccountMove = "move_share"
        case stockAccountSectionMove = "select_share_to_move"
        case loanOn = "unlock_loan"
        case loanOff = "lock_loan"
        case loanMove = "move_loan"
        case loanSectionMove = "select_loan_to_move"
        case depositOn = "unlock_deposit"
        case depositOff = "lock_deposit"
        case depositMove = "move_deposit"
        case depositSectionMove = "select_deposit_to_move"
        case pensionOn = "unlock_pension_plan"
        case pensionOff = "lock_pension_plan"
        case pensionMove = "move_pension_plan"
        case pensionSectionMove = "select_pension_plan_to_move"
        case fundOn = "unlock_fund"
        case fundOff = "lock_fund"
        case fundMove = "move_fund"
        case fundSectionMove = "select_fund_to_move"
        case insuranceProtectionOn = "unlock_insurances"
        case insuranceProtectionOff = "lock_insurance"
        case insuranceProtectionMove = "move_insurance"
        case insuranceProtectionSectionMove = "select_insurance_to_move"
        case insuranceSavingOn = "unlock_saving_insurances"
        case insuranceSavingOff = "lock_saving_insurance"
        case insuranceSavingMove = "move_saving_insurances"
        case insuranceSavingSectionMove = "select_saving_insurance_to_move"
        case save = "save_product_settings"
    }
    public init() {}
    
    public func changedSwitchTrackAction(type: ProductTypeEntity, isVisible: Bool) -> Action? {
        let valuesIsVisible: [ProductTypeEntity: Action] = [
            .account: .accountOn,
            .card: .cardOn,
            .savingProduct: .savingProductOn,
            .stockAccount: .stockAccountOn,
            .loan: .loanOn,
            .deposit: .depositOn,
            .pension: .pensionOn,
            .fund: .fundOn,
            .insuranceProtection: .insuranceProtectionOn,
            .insuranceSaving: .insuranceSavingOn
        ]
        let valuesNotVisible: [ProductTypeEntity: Action] = [
            .account: .accountOff,
            .card: .cardOff,
            .savingProduct: .savingProductOff,
            .stockAccount: .stockAccountOff,
            .loan: .loanOff,
            .deposit: .depositOff,
            .pension: .pensionOff,
            .fund: .fundOff,
            .insuranceProtection: .insuranceProtectionOff,
            .insuranceSaving: .insuranceSavingOff
        ]
        return isVisible ? valuesIsVisible[type]: valuesNotVisible[type]
    }
    
    public func moveTrackAction(type: ProductTypeEntity) -> Action? {
        let values: [ProductTypeEntity: Action] = [
            .account: .accountMove,
            .card: .cardMove,
            .savingProduct: .savingProductMove,
            .stockAccount: .stockAccountMove,
            .loan: .loanMove,
            .deposit: .depositMove,
            .pension: .pensionMove,
            .fund: .fundMove,
            .insuranceProtection: .insuranceProtectionMove,
            .insuranceSaving: .insuranceSavingMove
        ]
        return values[type]
    }
    
    public func moveSectionTrackAction(type: ProductTypeEntity) -> Action? {
        let values: [ProductTypeEntity: Action] = [
            .account: .accountSectionMove,
            .card: .cardSectionMove,
            .savingProduct: .savingProductSectionMove,
            .stockAccount: .stockAccountSectionMove,
            .loan: .loanSectionMove,
            .deposit: .depositSectionMove,
            .pension: .pensionSectionMove,
            .fund: .fundSectionMove,
            .insuranceProtection: .insuranceProtectionSectionMove,
            .insuranceSaving: .insuranceSavingSectionMove
        ]
        return values[type]
    }
}

public struct PersonalAreaConfigurationPhotoThemePGPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/personal_area/configuration/photo"
    
    public enum Action: String {
        case photoThemeSwipe = "swipe_photo_type"
        case photoThemeChange = "change_photo_type"
    }
    public init() {}
}

public struct PersonalAreaUpdateAccessKey: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "area_personal_cambiar_clave_de_acceso_nueva_clave"
    
    public enum Action: String {
        case seePass = "ver_clave"
        case error
        case okResponse
    }
    public init() {}
}
