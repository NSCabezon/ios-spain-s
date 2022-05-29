import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public class InsertConnectionDateUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let managersProvider: BSANManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = managersProvider.getLastLogonManager()
        _ = try manager.insertDateUpdate()
        return .ok()
    }
}
