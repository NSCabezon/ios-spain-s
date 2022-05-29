public protocol BSANTimeLineManager {
    func getMovements(_ input: TimeLineMovementsParameters) throws -> BSANResponse<TimeLineResponseDTO>
}
