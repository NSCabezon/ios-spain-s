import SANLegacyLibrary

public class BSANEnvironmentsManagerImplementation: BSANBaseManager, BSANEnvironmentsManager {

    private var bsanHostProvider: BSANHostProviderProtocol

    public init(bsanHostProvider: BSANHostProviderProtocol, bsanDataProvider: BSANDataProvider) {
        self.bsanHostProvider = bsanHostProvider
        super.init(bsanDataProvider: bsanDataProvider)
        initEnvironment()
    }

    public func getEnvironments() -> BSANResponse<[BSANEnvironmentDTO]> {
        return BSANOkResponse(bsanHostProvider.getEnvironments())
    }

    public func getCurrentEnvironment() -> BSANResponse<BSANEnvironmentDTO> {
        if let environment = try? bsanDataProvider.getEnvironment() {
            return BSANOkResponse(environment)
        } else {
           return BSANErrorResponse(nil)
        }
    }

    public func setEnvironment(bsanEnvironment: BSANEnvironmentDTO) -> BSANResponse<Void> {
        BSANLogger.i(logTag, "setEnvironment -> \(bsanEnvironment)")
        bsanDataProvider.storeEnviroment(bsanEnvironment)
        return BSANOkEmptyResponse()
    }

    public func setEnvironment(bsanEnvironmentName: String) -> BSANResponse<Void> {
        BSANLogger.i(logTag, "setEnvironment -> \(bsanEnvironmentName)")
        if let bsanEnvironment = bsanHostProvider.getEnvironments().first(where: { $0.name == bsanEnvironmentName }) {
            _ = setEnvironment(bsanEnvironment: bsanEnvironment)
        }
        return BSANOkEmptyResponse()
    }

    private func initEnvironment() {
        guard let _ = try? bsanDataProvider.getEnvironment() else {
            bsanDataProvider.storeEnviroment(bsanHostProvider.environmentDefault)
            return
        }
    }
}
