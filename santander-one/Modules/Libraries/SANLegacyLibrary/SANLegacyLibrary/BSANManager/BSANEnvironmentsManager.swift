public protocol BSANEnvironmentsManager {
    func getEnvironments() -> BSANResponse<[BSANEnvironmentDTO]>
    func getCurrentEnvironment() -> BSANResponse<BSANEnvironmentDTO>
    func setEnvironment(bsanEnvironment: BSANEnvironmentDTO) -> BSANResponse<Void>
    func setEnvironment(bsanEnvironmentName: String) -> BSANResponse<Void>
}
