import SANLibraryV3

public protocol HostsModuleProtocol {
    static func providesBSANHostProvider() -> BSANHostProvider
    static func providesPublicFilesHostProvider() -> PublicFilesHostProvider
    static func providesMapPoiHostProvider() -> MapPoiHostProvider
    static func providesInbentaHostProvider() -> InbentaHostProvider
}

extension HostsModuleProtocol {
    static func providesInbentaHostProvider() -> InbentaHostProvider {
        return InbentaHostProviderImpl()
    }
}

private struct InbentaHostProviderImpl: InbentaHostProvider {
    private(set) var inbentaEnvironments: [InbentaEnvironmentDTO] = []
}
