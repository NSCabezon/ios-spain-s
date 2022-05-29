import Foundation
import CoreFoundationLib
import ESCommons

public class SaveDeviceIdUseCase: UseCase<SaveDeviceIdUseCaseInput, Void, StringErrorOutput> {
    private let compilation: SpainCompilationProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: SpainCompilationProtocol.self)
    }
    
    public override func executeUseCase(requestValues: SaveDeviceIdUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let query = KeychainQuery(service: compilation.service,
                                  account: compilation.keychainSantanderKey.deviceId,
                                  accessGroup: compilation.sharedTokenAccessGroup,
                                  data: requestValues.deviceId as NSCoding)
        do {
            try KeychainWrapper().save(query: query)
            return .ok()
        } catch {
            return .error(StringErrorOutput(nil))
        }
    }
}

public struct SaveDeviceIdUseCaseInput {
    let deviceId: String
    
    public init(deviceId: String) {
        self.deviceId = deviceId
    }
}
