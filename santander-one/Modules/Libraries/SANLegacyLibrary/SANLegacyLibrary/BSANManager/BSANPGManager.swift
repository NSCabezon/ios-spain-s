public protocol BSANPGManager {
    func loadGlobalPosition(onlyVisibleProducts: Bool, isPB: Bool) throws -> BSANResponse<GlobalPositionDTO>
    func loadGlobalPositionV2(onlyVisibleProducts: Bool, isPB: Bool) throws -> BSANResponse<GlobalPositionDTO>
    func getGlobalPosition() throws -> BSANResponse<GlobalPositionDTO>
}
