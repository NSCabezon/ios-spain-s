//
//  BottomMenuOption.swift
//  RetailClean
//
//  Created by Tania Castellano Brasero on 21/10/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

protocol PrivateSideMenuFooterProtocol: AnyObject {
    var dependencies: PresentationComponent { get }
    var actionNavigator: PrivateHomeNavigator & PrivateHomeNavigatorSideMenu { get }
    func didTapHelpUs()
    func showFeatureNotAvailableToast()
}

extension PrivateSideMenuFooterProtocol {
    
    var opinatorTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("menu_link_improve")
    }
    
    private var localAppConfig: LocalAppConfig {
        self.dependencies.localAppConfig
    }
    
    func bottomOptions(hasManager: Bool) -> [PrivateMenuOption] {
        var result = [PrivateMenuOption]()
        for option in BottomMenuOption.allCases {
            let menuOption = generateOptionFor(option, hasManager: hasManager)
            result.append(menuOption)
            option.imageURL(using: dependencies) { (url) in
                menuOption.imageURL = url
            }
        }
        
        return result
    }
    
    private func generateOptionFor(_ option: BottomMenuOption, hasManager: Bool) -> MenuOptionData {
		return MenuOptionData(title: dependencies.stringLoader.getString(option.titleKey),
                              iconKey: option.iconKey(isManagerPresent: hasManager),
                              coachmarkId: option.coachmarkId,
                              accessibilityIdentifier: option.accessibilityIdentifier) { [weak self] in
            self?.selectedBarOption(option)
        }
    }
    
    fileprivate func selectedBarOption(_ option: BottomMenuOption) {
        actionNavigator.closeSideMenu()
        switch option {
        case .security:
            guard localAppConfig.isEnabledGoToPersonalArea else {
                self.showNotAvailableToast()
                return
            }
            actionNavigator.goToSecurityArea()
        case .atm:
            if localAppConfig.isEnabledATMsInMenu {
                if localAppConfig.showATMIntermediateScreen {
                    actionNavigator.goToAtm()
                } else {
                    actionNavigator.goToATMLocator(keepingNavigation: true)
                }
            } else {
                self.showNotAvailableToast()
                return
            }
        case .helpCenter:
            guard localAppConfig.isEnabledGoToHelpCenter else {
                self.showNotAvailableToast()
                return
            }
            actionNavigator.goToHelpCenter()
        case .myManager:
            guard localAppConfig.isEnabledGoToManager else {
                self.showNotAvailableToast()
                return
            }
            actionNavigator.goToManager()
        }
    }
    
    func showNotAvailableToast() {
        let message: LocalizedStylableText = dependencies.stringLoader.getString("generic_alert_notAvailableOperation")
        Toast.show(message.text)
    }
}
    
private enum BottomMenuOption: CaseIterable, ManagerImageURLFetcher {
    case security
    case atm
    case helpCenter
    case myManager
    
    var titleKey: String {
        switch self {
        case .security:
            return "menu_link_security"
        case .atm:
            return "menu_link_atm"
        case .helpCenter:
            return "menu_link_HelpCenter"
        case .myManager:
            return "menu_link_menuMyManage"
        }
    }
    
    func iconKey(isManagerPresent: Bool = false) -> String {
        switch self {
        case .security:
            return "icnSecurity"
        case .atm:
            return "icnAtmMenu"
        case .helpCenter:
            return "icnSupportMenu"
        case .myManager:
            return isManagerPresent ? "icnMyManagerDefault" : "icnMyManager"
        }
    }
    
    var coachmarkId: CoachmarkIdentifier? {
        switch self {
        case .myManager:
            return .sideMenuManager
        default:
            return nil
        }
    }
    
    func imageURL(using dependencies: PresentationComponent, completion: @escaping (String?) -> Void) {
        guard self == .myManager else {
            completion(nil)
            return
        }
        
        requestManagerImageURL(using: dependencies, completion: completion)
    }
}

extension BottomMenuOption: AccessibilityProtocol {
	var accessibilityIdentifier: String? {
		switch self {
		case .security:
			return AccessibilitySideMenu.btnSecurity
		case .atm:
			return AccessibilitySideMenu.btnAtm
		case .helpCenter:
			return AccessibilitySideMenu.btnHelpCenter
		case .myManager:
			return AccessibilitySideMenu.btnMenuMyManage
		}
	}
}
