import SANLegacyLibrary

struct MockBSANTouchIdManager: BSANTouchIdManager {
    func registerTouchId(footPrint: String, deviceName: String) throws -> BSANResponse<TouchIdRegisterDTO> {
        fatalError()
    }
}
