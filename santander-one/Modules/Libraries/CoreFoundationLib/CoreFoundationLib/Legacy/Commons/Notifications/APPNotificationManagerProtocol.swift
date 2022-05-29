
public protocol OtpNotificationHandler: AnyObject {
    func handleOTPCode(_ code: String?, date: Date?)
}

public protocol OtpPushManagerProtocol {
    func handleOTP()
    func registerOtpHandler(handler: OtpNotificationHandler)
    func unregisterOtpHandler()
    func removeOtpFromUserPref()
    func didRegisterForRemoteNotifications(deviceToken: Data)
    func registerOtpPushAndSaveToken(deviceId: String)
    func updateToken(completion: @escaping ((_ isNew: Bool, _ returnCode: ReturnCodeOTPPush?) -> Void))
    func getDeviceToken() -> Data?
}

public protocol NotificationDeviceInfoProvider {
    func getDeviceUDID() -> String?
    func getVersionNumber() -> String?
    func getDeviceID() -> String?
}

public protocol APPNotificationManagerBridgeProtocol {
    func getOtpPushManager() -> OtpPushManagerProtocol?
}
