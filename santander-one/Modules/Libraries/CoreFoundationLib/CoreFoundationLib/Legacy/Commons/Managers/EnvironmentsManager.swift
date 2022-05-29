import SANLegacyLibrary
import CoreDomain

public protocol HostProviderProtocol {
    func getEnvironments() -> [EnvironmentsRepresentable]
    var environmentDefault: EnvironmentsRepresentable { get }
}

public protocol EnvironmentsManagerProtocol {
    func getEnvironments() -> Result<[EnvironmentsRepresentable], Error>
    func getCurrentEnvironment() -> Result<EnvironmentsRepresentable, Error>
    func setEnvironment(_ environment: EnvironmentsRepresentable) -> Result<Void, Error>
    func setEnvironment(_ environmentName: String) -> Result<Void, Error>
}

enum EnvironmentsError: Error {
    case environmentNotFound
    case environmentsNotFound
}

public final class EnvironmentsManager {
    private let hostProvider: HostProviderProtocol
    private let dataProvider: EnvironmentDataProviderProtocol
    
    init(dataProvider: EnvironmentDataProviderProtocol, hostProvider: HostProviderProtocol) {
        self.hostProvider = hostProvider
        self.dataProvider = dataProvider
        self.initEnvironment()
    }
}

private extension EnvironmentsManager {
    func initEnvironment() {
        self.dataProvider.storeEnviroment(self.hostProvider.environmentDefault)
    }
}

extension EnvironmentsManager: EnvironmentsManagerProtocol {
    public func getEnvironments() -> Result<[EnvironmentsRepresentable], Error> {
        return .success(self.hostProvider.getEnvironments())
    }
    
    public func getCurrentEnvironment() -> Result<EnvironmentsRepresentable, Error> {
        guard let environment = try? self.dataProvider.getEnvironment() else {
            return .failure(EnvironmentsError.environmentNotFound)
        }
        return .success(environment)
    }
    
    public func setEnvironment(_ environment: EnvironmentsRepresentable) -> Result<Void, Error> {
        self.dataProvider.storeEnviroment(environment)
        return .success(())
    }
    
    public func setEnvironment(_ environmentName: String) -> Result<Void, Error> {
        guard let environment = self.hostProvider.getEnvironments().first(where: { $0.name == environmentName }) else {
            return .failure(EnvironmentsError.environmentNotFound)
        }
        _ = self.setEnvironment(environment)
        return .success(())
    }
}

public protocol EnvironmentDataProviderProtocol {
    func getEnvironment() throws -> EnvironmentsRepresentable
    func storeEnviroment(_ environment: EnvironmentsRepresentable)
}
