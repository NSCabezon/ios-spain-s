import CoreDomain


public enum AppLanguage: String {
    case spanish = "es"
    case spanishPB = "zu"
    case catala = "ca"
    case english = "en"
    case galician = "gl"
    case euskera = "eu"
    case french = "fr"
    case italian = "it"
    case portuguese = "pt"
    case portuguesePT = "pj"
    case polish = "pl"
    case ukrainian = "uk"
    case russian = "ru"
}

public enum LanguageGroup: String {
    case latin
    case cyrillic
}

public enum LanguageType: String, Codable, CaseIterable {
    case spanish = "es"
    case catala = "ca"
    case galician = "gl"
    case euskera = "eu"
    case english = "en"
    case french = "fr"
    case italian = "it"
    case portuguese = "pt"
    case portuguesePT = "pj"
    case polish = "pl"
    case ukrainian = "uk"
    case russian = "ru"

    public var languageName: String {
        switch self {
        case .portuguesePT:
            return "language_label_youngPortuguese"
        case .spanish, .catala, .galician, .euskera, .english, .french, .italian, .portuguese, .polish, .ukrainian, .russian:
            return locale.localizedString(forLanguageCode: languageCode) ?? ""
        }
    }
    
    public var languageGroup: LanguageGroup {
        switch self {
        case .ukrainian, .russian:
            return .cyrillic
        default:
            return .latin
        }
    }
    
    public var locale: Locale {
        return Locale(identifier: languageCode)
    }
    
    public var trackerId: String {
        switch self {
        case .spanish:
            return "es_es"
        case .catala:
            return "ca_es"
        case .galician:
            return "gl_es"
        case .euskera:
            return "eu"
        case .english:
            return "en_gb"
        case .french:
            return "fr_fr"
        case .italian:
            return "it_it"
        case .portuguese:
            return "pt_pt"
        case .portuguesePT:
            return "pj_pt"
        case .polish:
            return "pl_pl"
        case .ukrainian:
            return "uk_uk"
        case .russian:
            return "ru_ru"
        }
    }
    
    public var languageCode: String {
        switch self {
        case .spanish:
            return "es_ES"
        case .catala:
            return "ca_ES"
        case .english:
            return "en"
        case .galician:
            return "gl_ES"
        case .euskera:
            return "eu_ES"
        case .french:
            return "fr_FR"
        case .italian:
            return "it_IT"
        case .portuguese, .portuguesePT:
            return "pt_PT"
        case .polish:
            return "pl_PL"
        case .ukrainian:
            return "uk_UK"
        case .russian:
            return "ru_RU"
        }
    }
}

public struct Language {
    public let languageType: LanguageType
    public var isPb: Bool
    
    public var appLanguageCode: String {
        let appLanguage: AppLanguage
        switch languageType {
        case .spanish:
            appLanguage = isPb ? .spanishPB: .spanish
        case .catala:
            appLanguage = .catala
        case .english:
            appLanguage = .english
        case .galician:
            appLanguage = .galician
        case .euskera:
            appLanguage = .euskera
        case .french:
            appLanguage = .french
        case .italian:
            appLanguage = .italian
        case .portuguese:
            appLanguage = .portuguese
        case .portuguesePT:
            appLanguage = .portuguesePT
        case .polish:
            appLanguage = .polish
        case .ukrainian:
            appLanguage = .ukrainian
        case .russian:
            appLanguage = .russian
        }
        return appLanguage.rawValue
    }
    
    private static func getDeviceLanguageType(availableLanguageList: [LanguageType]) -> LanguageType? {
        guard let language = Locale.preferredLanguages.first?.substring(0, 2) else {
            return nil
        }
        if isAvailableAppLanguageType(language: language, availableLanguageList: availableLanguageList) {
            return LanguageType(rawValue: language)
        } else {
            return nil
        }
    }
    
    private static func isAvailableAppLanguageType(language: String, availableLanguageList: [LanguageType]) -> Bool {
        for availableLanguage in availableLanguageList where language == availableLanguage.rawValue {
            return true
        }
        return false
    }
    
    public static func createDefault(isPb: Bool?, defaultLanguage: LanguageType, availableLanguageList: [LanguageType]) -> Language {
        guard let language = Language.getDeviceLanguageType(availableLanguageList: availableLanguageList) else {
            return Language.createFromType(languageType: defaultLanguage, isPb: isPb)
        }
        return Language.createFromType(languageType: language, isPb: isPb)
    }
    
    public static func createFromType(languageType: LanguageType, isPb: Bool?) -> Language {
        return Language(languageType: languageType, isPb: isPb == true)
    }
}

extension LanguageType {
    public var getPublicLanguage: PublicLanguage {
        switch self {
        case .spanish:
            return PublicLanguage.spanish
        case .catala:
            return PublicLanguage.catala
        case .english:
            return PublicLanguage.english
        case .galician:
            return PublicLanguage.galician
        case .euskera:
            return PublicLanguage.euskera
        case .french:
            return PublicLanguage.french
        case .italian:
            return PublicLanguage.italian
        case .portuguese, .portuguesePT:
            return PublicLanguage.portuguese
        case .polish:
            return PublicLanguage.polish
        case .ukrainian:
            return PublicLanguage.ukrainian
        case .russian:
            return PublicLanguage.russian
        }
    }
}
