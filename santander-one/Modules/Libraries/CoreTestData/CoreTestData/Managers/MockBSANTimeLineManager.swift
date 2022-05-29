import SANLegacyLibrary

struct MockBSANTimeLineManager: BSANTimeLineManager {
    func getMovements(_ input: TimeLineMovementsParameters) throws -> BSANResponse<TimeLineResponseDTO> {
        fatalError()
    }
}
