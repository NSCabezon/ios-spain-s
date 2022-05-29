import Foundation

public enum PhotoPermissionType {
    case photoLibraryAccess
    case cameraAccess
}

public enum PhotoPermissionAuthorizationStatus {
    case authorized
    case denied
    case notDetermined
    case restricted
}

public class PhotoPermissionHelper {
    public var isPhotoAccessAlreadySet: Bool {
        return authorizationStatus(type: .photoLibraryAccess) != .notDetermined
    }
    
    public var isCameraAccessAlreadySet: Bool {
        return authorizationStatus(type: .cameraAccess) != .notDetermined
    }
    
    public init() {}
    
    private func getPermissionAuthorization(for type: PhotoPermissionType) -> CameraPermissionAuthorizatorProtocol {
        switch type {
        case .photoLibraryAccess:
            return PhotoLibraryPermissionAuthorizator()
        case .cameraAccess:
            return CameraPermissionAuthorizator()
        }
    }
    
    public func authorizationStatus(type: PhotoPermissionType) -> PhotoPermissionAuthorizationStatus {
        let authorization = getPermissionAuthorization(for: type)
        return authorization.authorizationStatus()
    }
    
    public func askAuthorization(type: PhotoPermissionType, completion: @escaping (_ authorized: Bool) -> Void) {
        let authorization = getPermissionAuthorization(for: type)
        authorization.askAuthorization(completion: completion)
    }
}
