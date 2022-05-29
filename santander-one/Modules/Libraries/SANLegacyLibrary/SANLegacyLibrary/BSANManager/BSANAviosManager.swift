public protocol BSANAviosManager {
    func getAviosDetail() throws -> BSANResponse<AviosDetailDTO>
}
