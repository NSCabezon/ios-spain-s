import SANLegacyLibrary

public protocol HostsModuleProtocol {
    func providesBSANHostProvider() -> BSANHostProviderProtocol
    func providesPublicFilesHostProvider() -> PublicFilesHostProviderProtocol
    func providesInbentaHostProvider() -> InbentaHostProvider
}

public extension HostsModuleProtocol {
    func providesInbentaHostProvider() -> InbentaHostProvider {
        return InbentaHostProviderImpl()
    }
}

private struct InbentaHostProviderImpl: InbentaHostProvider {
    private(set) var inbentaEnvironments: [InbentaEnvironmentDTO] = []
}
