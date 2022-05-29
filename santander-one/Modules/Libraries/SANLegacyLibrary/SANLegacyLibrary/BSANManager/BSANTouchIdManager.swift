public protocol BSANTouchIdManager {
    func registerTouchId(footPrint: String, deviceName: String) throws -> BSANResponse<TouchIdRegisterDTO>
}
