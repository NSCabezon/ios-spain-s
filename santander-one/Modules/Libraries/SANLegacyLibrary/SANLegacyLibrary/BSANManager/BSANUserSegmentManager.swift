public protocol BSANUserSegmentManager {
    func getUserSegment() throws -> BSANResponse<UserSegmentDTO>
    func loadUserSegment() throws -> BSANResponse<UserSegmentDTO>
    func saveIsSelectUSer(_ isSelect: Bool)
    func isSelectUser() throws -> Bool
    func saveIsSmartUser(_ isSmart: Bool)
    func isSmartUser() throws -> Bool
}
