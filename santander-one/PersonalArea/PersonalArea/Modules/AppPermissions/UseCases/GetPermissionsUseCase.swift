import CoreFoundationLib

class GetPermissionsUseCase: UseCase<Void, GetPermissionsUseCaseOkOutput, StringErrorOutput> {

    private let dependenciesResolver: DependenciesResolver
    private let cameraPermission = PhotoPermissionHelper()
    
    private var isLocationAccessEnabled: Bool {
        let locationPermissionManager: LocationPermissionsManagerProtocol = self.dependenciesResolver.resolve(for: LocationPermissionsManagerProtocol.self)
        return locationPermissionManager.isLocationAccessEnabled()
    }
    private var isContactAccessEnabled: Bool {
        let contacts: ContactPermissionsManagerProtocol = self.dependenciesResolver.resolve(for: ContactPermissionsManagerProtocol.self)
        return contacts.isContactsAccessEnabled()
    }
    private var isPhotoAccessEnabled: Bool {
        return cameraPermission.authorizationStatus(type: .photoLibraryAccess) == .authorized
    }
    private var isCameraAccessEnabled: Bool {
        return cameraPermission.authorizationStatus(type: .cameraAccess) == .authorized
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPermissionsUseCaseOkOutput, StringErrorOutput> {
        let dispatchGroup  = DispatchGroup()
        var isNotificationAccessEnabled: Bool = false
        if let notifications = self.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self) {
            dispatchGroup.enter()
            notifications.isNotificationsEnabled { response in
                isNotificationAccessEnabled = response
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }
        let response = GetPermissionsUseCaseOkOutput(isLocationEnabled: isLocationAccessEnabled, isContactEnabled: isContactAccessEnabled, isPhotoEnabled: isPhotoAccessEnabled, isCameraEnabled: isCameraAccessEnabled, isNotificationEnabled: isNotificationAccessEnabled)
        return UseCaseResponse.ok(response)
    }
}

struct GetPermissionsUseCaseOkOutput {
    let isLocationEnabled: Bool
    let isContactEnabled: Bool
    let isPhotoEnabled: Bool
    let isCameraEnabled: Bool
    let isNotificationEnabled: Bool
}
