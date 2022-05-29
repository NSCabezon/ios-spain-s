public protocol BSANHostProviderProtocol {
    func getEnvironments() -> [BSANEnvironmentDTO]
    var environmentDefault: BSANEnvironmentDTO { get }
}
