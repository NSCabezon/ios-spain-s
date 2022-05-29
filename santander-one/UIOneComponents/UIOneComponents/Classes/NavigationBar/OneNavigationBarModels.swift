import UIKit
import UI

public enum OneNavigationBarStyle {
    case whiteWithRedComponents, transparentWithWhiteComponents
    
    var barTintColor: UIColor {
        switch self {
        case .whiteWithRedComponents:
            return .white
        case .transparentWithWhiteComponents:
            return .clear
        }
    }
    
    var isTransparent: Bool {
        switch self {
        case .whiteWithRedComponents:
            return false
        case .transparentWithWhiteComponents:
            return true
        }
    }
    
    var titleTextColor: UIColor {
        switch self {
        case .whiteWithRedComponents:
            return .oneSantanderRed
        case .transparentWithWhiteComponents:
            return .white
        }
    }
    
    var buttonTextColor: UIColor {
        switch self {
        case .whiteWithRedComponents:
            return .oneLisboaGray
        case .transparentWithWhiteComponents:
            return .white
        }
    }
    
    var buttonImageTintColor: UIColor {
        switch self {
        case .whiteWithRedComponents:
            return .oneSantanderRed
        case .transparentWithWhiteComponents:
            return .white
        }
    }
}

public enum OneNavigationBarLeftButtonModel {
    case back
    case santanderLogo(OneNavigationBarSantanderLogo)
}

public enum OneNavigationBarSantanderLogo {
    case normal
    case privateBanking
    case smart
    case select
    
    func getImageKey(style: OneNavigationBarStyle) -> String {
        switch style {
        case .transparentWithWhiteComponents:
            return getImageKeyForTransparent()
        case .whiteWithRedComponents:
            return getImageKeyForWhite()
        }
    }
    
    private func getImageKeyForTransparent() -> String {
        switch self {
        case .normal: return "icnSantanderWhite"
        case .privateBanking: return "icnPbpgSmart"
        case .select: return "icnSelectPgSmart"
        case .smart: return "icnSmartPgSmart"
        }
    }
    
    private func getImageKeyForWhite() -> String {
        switch self {
        case .normal: return "icnSantander"
        case .privateBanking: return "icnPbpg"
        case .select: return "icnSelectPg"
        case .smart: return "icnSmartPg"
        }
    }
}

public enum OneNavigationBarButtonModel {
    case close
    case menu
    case search
    case mail
    case help
    
    var imageKey: String {
        switch self {
        case .close: return "oneIcnClose"
        case .help: return "oneIcnFaqs"
        case .menu: return "oneIcnMenu"
        case .mail: return "oneIcnEnvelop"
        case .search: return "oneIcnSearch"
        }
    }
    
    var text: String {
        switch self {
        case .close: return "generic_button_close"
        case .help: return "generic_label_help"
        case .menu: return "generic_label_menu"
        case .mail: return "generic_label_mailbox"
        case .search: return "generic_label_search"
        }
    }
    
    var accessibilityLabelKey: String {
        switch self {
        case .close: return "generic_button_close"
        case .help: return "voiceover_helpInformation"
        case .menu: return "generic_label_menu"
        case .mail: return "generic_label_mailbox"
        case .search: return "generic_label_search"
        }
    }
}

public enum OneNavigationBarTitleImage {
    case image(UIImage)
    case key(String)
    
    var image: UIImage? {
        switch self {
        case .image(let image):
            return image
        case .key(let key):
            return Assets.image(named: key)?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var accessibilityIdentifier: String? {
        switch self {
        case .image(let image):
            return image.accessibilityIdentifier
        case .key(let key):
            return key
        }
    }
}
