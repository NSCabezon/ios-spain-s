import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetPermissionsStatusUseCase: UseCase<Void, GetPermissionsStatusUseCaseOkOutput, StringErrorOutput> {

    private let dependencies: PresentationComponent
    private let contacts = ContactsStoreManager()
    private let cameraPermission = PhotoPermissionHelper()
    
    private var isLocationAccessEnabled: Bool {
        return dependencies.locationManager.locationServicesStatus() == .authorized
    }
    
    private var isContactAccessEnabled: Bool {
        return contacts.isPermissionEnabledStatus
    }
    
    private var isPhotoAccessEnabled: Bool {
        return cameraPermission.authorizationStatus(type: .photoLibraryAccess) == .authorized
    }
    
    private var isCameraAccessEnabled: Bool {
        return cameraPermission.authorizationStatus(type: .cameraAccess) == .authorized
    }
    
    private var notificationPermissionsManager: PushNotificationPermissionsManagerProtocol? {
        self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPermissionsStatusUseCaseOkOutput, StringErrorOutput> {
        let dispatchGroup  = DispatchGroup()
        var result = [(PermissionSectionType, Bool)]()
        result.append((.location, isLocationAccessEnabled))
        result.append((.contacts, isContactAccessEnabled))
        result.append((.photos, isPhotoAccessEnabled))
        result.append((.camera, isCameraAccessEnabled))
        if let permissionsManager = notificationPermissionsManager {
            dispatchGroup.enter()
            permissionsManager.isNotificationsEnabled { isNotificationEnabled in
                result.append((.notifications, isNotificationEnabled))
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }
        let response = GetPermissionsStatusUseCaseOkOutput(items: result)
        return UseCaseResponse.ok(response)
    }
    
}

struct GetPermissionsStatusUseCaseOkOutput {
    let items: [(PermissionSectionType, Bool)]
}

enum PermissionSectionType {
    case location
    case contacts
    case photos
    case camera
    case notifications
}
