import Photos
import AVFoundation

protocol CameraPermissionAuthorizatorProtocol {
    func authorizationStatus() -> PhotoPermissionAuthorizationStatus
    func askAuthorization(completion: @escaping (_ authorized: Bool) -> Void)
}

class PhotoLibraryPermissionAuthorizator: CameraPermissionAuthorizatorProtocol {
    func authorizationStatus() -> PhotoPermissionAuthorizationStatus {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
    func askAuthorization(completion: @escaping (_ authorized: Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization({ authorizationStatus in
            switch authorizationStatus {
            case .authorized:
                completion(true)
            case .denied, .notDetermined, .restricted:
                completion(false)
            @unknown default:
                completion(false)
            }
        })
    }
}

class CameraPermissionAuthorizator: CameraPermissionAuthorizatorProtocol {
    func authorizationStatus() -> PhotoPermissionAuthorizationStatus {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
    func askAuthorization(completion: @escaping (_ authorized: Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { accepted in
            DispatchQueue.main.async {
                completion(accepted)
            }
        })
    }
}
