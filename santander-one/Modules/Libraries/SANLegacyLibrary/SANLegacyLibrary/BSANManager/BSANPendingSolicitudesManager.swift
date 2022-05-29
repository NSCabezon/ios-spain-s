public protocol BSANPendingSolicitudesManager {
    func getPendingSolicitudes() throws -> BSANResponse<PendingSolicitudeListDTO>
    func removePendingSolicitudes()
}
