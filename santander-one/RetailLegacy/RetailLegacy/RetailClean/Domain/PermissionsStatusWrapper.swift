//
//  PermissionsStatusWrapper.swift
//  RetailLegacy
//
//  Created by Victor Carrilero García on 10/02/2021.
//

import Foundation
import CoreFoundationLib

protocol PermissionsStatusWrapperProtocol {
    func getPermissions() -> [FirstBoardingPermissionTypeItem]
    func getLocalAuthenticationPermissionsManagerProtocol() -> LocalAuthenticationPermissionsManagerProtocol
}

final class PermissionsStatusWrapper {
    private let dependencies: DependenciesResolver
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
}

extension PermissionsStatusWrapper: PermissionsStatusWrapperProtocol {
    func getPermissions() -> [FirstBoardingPermissionTypeItem] {
        let options: [FirstBoardingPermissionType]
        if let permissionsOptions: OnboardingPermissionOptionsProtocol = self.dependencies.resolve(forOptionalType: OnboardingPermissionOptionsProtocol.self),
           let customOptions = permissionsOptions.getOptions() as? [FirstBoardingPermissionType] {
            options = customOptions
        } else {
            options = [.touchId, .notifications, .location]
        }
        var result = [FirstBoardingPermissionTypeItem]()
        for option in options {
            result.append(self.getOption(option))
        }
        return result
    }
}

extension PermissionsStatusWrapper: PermissionOptionProtocol {
    func getLocalAuthenticationPermissionsManagerProtocol() -> LocalAuthenticationPermissionsManagerProtocol {
        if let permissionsOptions: PermissionOptionProtocol = self.dependencies.resolve(forOptionalType: PermissionOptionProtocol.self) {
            return permissionsOptions.getLocalAuthenticationPermissionsManagerProtocol()
        } else {
            return KeychainAuthentication(appEventsNotifier: AppEventsNotifier(), dependenciesResolver: self.dependencies)
        }
    }
}

private extension PermissionsStatusWrapper {
    var compilation: CompilationProtocol  {
        return self.dependencies.resolve(for: CompilationProtocol.self)
    }
    var isTouchIdEnabled: Bool {
        let touchIdData = KeychainWrapper().touchIdData(compilation: compilation)
        return touchIdData?.touchIDLoginEnabled ?? false
    }
    var isLocationAccessEnabled: Bool {
        let locationManger: LocationPermissionsManagerProtocol = self.dependencies.resolve(for: LocationPermissionsManagerProtocol.self)
        return locationManger.locationServicesStatus() == .authorized
    }
    
    func getOption(_ type: FirstBoardingPermissionType) -> FirstBoardingPermissionTypeItem {
        let result: FirstBoardingPermissionTypeItem
        switch type {
        case .touchId:
            result = self.touchIdOption()
        case .notifications(title: let title):
            result = self.notificationsOption(title)
        case .location(title: let title):
            result = self.locationOption(title)
        case .custom(options: let options):
            result = self.customOption(options)
        case .customWithTooltip(options: let options):
            result = self.customOption(options)
        }
        return result
    }
    
    func touchIdOption() -> FirstBoardingPermissionTypeItem {
        return (.touchId, [self.isTouchIdEnabled])
    }
    
    func notificationsOption(_ title: String? = nil) -> FirstBoardingPermissionTypeItem {
        var result: FirstBoardingPermissionTypeItem = (.notifications(title: title), [false])
        if let pushNotificationsManager = self.dependencies.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self) {
            let dispatchGroup  = DispatchGroup()
            dispatchGroup.enter()
            pushNotificationsManager.isNotificationsEnabled { isNotificationEnabled in
                result = (.notifications(title: title), [isNotificationEnabled])
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }
        return result
    }
    
    func locationOption(_ title: String? = nil) -> FirstBoardingPermissionTypeItem {
        return (.location(title: title), [self.isLocationAccessEnabled])
    }
    
    func customOption(_ options: CustomOptionOnbarding) -> FirstBoardingPermissionTypeItem {
        let result: FirstBoardingPermissionTypeItem = (.custom(options: options), [options.isEnabled()])
        return result
    }
    
    func customOption(_ options: CustomOptionWithTooltipOnbarding) -> FirstBoardingPermissionTypeItem {
        let result: FirstBoardingPermissionTypeItem = (.customWithTooltip(options: options), options.cell.map { $0.isEnabled() })
        return result
    }
}
