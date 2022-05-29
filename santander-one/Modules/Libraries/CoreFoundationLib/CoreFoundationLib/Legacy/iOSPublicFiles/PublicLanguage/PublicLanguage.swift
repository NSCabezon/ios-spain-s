//

import Foundation

public enum PublicLanguage {
    case spanish
    case catala
    case english
    case galician
    case euskera
    case french
    case italian
    case portuguese
    case portuguesePT
    case polish
    case ukrainian
    case russian
    
    public var prefix: String {
        switch self {
        case .spanish:
            return ""
        case .catala:
            return "ca_"
        case .english:
            return "en_"
        case .galician:
            return "gl_"
        case .euskera:
            return "eu_"
        case .french:
            return "fr_"
        case .italian:
            return "it_"
        case .portuguese:
            return "pt_"
        case .portuguesePT:
            return "pj_"
        case .polish:
            return "pl_"
        case .ukrainian:
            return "uk_"
        case .russian:
            return "ru_"
        }
    }
}
