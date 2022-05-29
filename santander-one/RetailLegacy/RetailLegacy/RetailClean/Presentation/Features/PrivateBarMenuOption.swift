import UIKit
import UI

enum PrivateBarMenuOption: Int {
    case manager = 1
    case personalArea
    case atms
    case customerService
    case exit
    
    static func title(for optionNumber: Int) -> String? {
        guard let option = PrivateBarMenuOption(rawValue: optionNumber) else {
            return nil
        }
        switch option {
        case .manager:
            return "menu_link_menuMyManage"
        case .personalArea:
            return UIScreen.main.isIphone4or5 ? "menu_link_personalArea" : "menu_link_setting"
        case .atms:
            return "menu_link_cusumerService"
        case .customerService:
            return "menu_link_appSantander"
        case .exit:
            return "menu_link_exit"
        }
    }
    
    static func icon(for optionNumber: Int) -> UIImage? {
        guard let option = PrivateBarMenuOption(rawValue: optionNumber) else {
            return nil
        }
        switch option {
        case .manager:
            return Assets.image(named: "icnManagerMenu")
        case .personalArea:
            return Assets.image(named: "icnPersonalArea")
        case .atms:
            return Assets.image(named: "icnMapsMenu")
        case .customerService:
            return Assets.image(named: "icnSupportMenu")
        case .exit:
            return Assets.image(named: "icnExitMenu")
        }
    }
    
}
