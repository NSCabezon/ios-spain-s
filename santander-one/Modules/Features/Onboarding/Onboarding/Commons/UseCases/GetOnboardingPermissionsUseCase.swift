import Foundation
import OpenCombine
import CoreDomain
import RxCombine
import CoreFoundationLib

protocol GetOnboardingPermissionsUseCase {
    func fetch() -> AnyPublisher<OnboardingPermissions, Error>
}

class DefaultGetOnboardingPermissionsUseCase {
    private let locationManager: LocationPermissionsManagerProtocol
    private let compilation: CompilationProtocol
    private let pushNotificationsManager: PushNotificationPermissionsManagerProtocol
    private let onboardingOptions: OnboardingPermissionOptionsProtocol?
    
    init(dependencies: OnboardingCommonExternalDependenciesResolver) {
        locationManager = dependencies.resolve()
        compilation = dependencies.resolve()
        pushNotificationsManager = dependencies.resolve()
        onboardingOptions = dependencies.resolve()
    }
}

extension DefaultGetOnboardingPermissionsUseCase: GetOnboardingPermissionsUseCase {
    
    func fetch() -> AnyPublisher<OnboardingPermissions, Error> {
        let options: [OnboardingPermissionType]
        if let permissionsOptions = onboardingOptions {
            options = permissionsOptions.getOptions()
        } else {
            options = [.notifications, .location]
        }
        var result = OnboardingPermissions()
        for option in options {
            result.append(self.getOption(option))
        }
        return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
    }
    
}

private extension DefaultGetOnboardingPermissionsUseCase {
    func getOption(_ type: OnboardingPermissionType) -> (OnboardingPermissionType, [Bool]) {
        let result: (OnboardingPermissionType, [Bool])
        switch type {
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
        
    func notificationsOption(_ title: String? = nil) -> (OnboardingPermissionType, [Bool]) {
        var result: (OnboardingPermissionType, [Bool]) = (.notifications(title: title), [false])
        let dispatchGroup  = DispatchGroup()
        dispatchGroup.enter()
        pushNotificationsManager.isNotificationsEnabled { isNotificationEnabled in
            result = (.notifications(title: title), [isNotificationEnabled])
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        return result
    }
    
    func locationOption(_ title: String? = nil) -> (OnboardingPermissionType, [Bool]) {
        return (.location(title: title), [self.isLocationAccessEnabled])
    }
    
    func customOption(_ options: CustomOptionOnboarding) -> (OnboardingPermissionType, [Bool]) {
        let result: (OnboardingPermissionType, [Bool]) = (.custom(options: options), [options.isEnabled()])
        return result
    }
    
    func customOption(_ options: CustomOptionWithTooltipOnboarding) -> (OnboardingPermissionType, [Bool]) {
        let result: (OnboardingPermissionType, [Bool]) = (.customWithTooltip(options: options), options.cell.map { $0.isEnabled() })
        return result
    }
        
    var isLocationAccessEnabled: Bool {
        return locationManager.locationServicesStatus() == .authorized
    }
}
