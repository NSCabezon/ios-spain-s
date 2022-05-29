import Foundation
import CoreFoundationLib
import SANSpainLibrary
import SANServicesLibrary
import SANLibraryV3

final class UpdateEnvironmentUseCase: UseCase<UpdateEnvironmentUseCaseInput, Void, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: UpdateEnvironmentUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        self.dependenciesResolver.resolve(for: EnvironmentProvider.self).update(environment: requestValues.environment)
        return .ok()
    }
}

struct UpdateEnvironmentUseCaseInput {
    let environment: EnvironmentRepresentable
}
