import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetOtherOperativesUseCase: UseCase<GetOtherOperativesUseCaseInput, GetOtherOperativesUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetOtherOperativesUseCaseInput) throws -> UseCaseResponse<GetOtherOperativesUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let configuration = self.dependenciesResolver.resolve(for: OtherOperativesConfiguration.self)
        var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
        let accounts = globalPosition.accounts.filter({ $0.isVisible })
        if let userId: String = globalPosition.userId {
            for location in requestValues.locations {
                if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                    outputCandidates[location] = OfferEntity(candidate, location: location)
                }
            }
        }
        return .ok(GetOtherOperativesUseCaseOkOutput(pullOfferCandidates: outputCandidates, configuration: configuration, accounts: accounts))
    }
}

struct GetOtherOperativesUseCaseInput {
    let locations: [PullOfferLocation]
}

struct GetOtherOperativesUseCaseOkOutput {
    let pullOfferCandidates: [PullOfferLocation: OfferEntity]
    let configuration: OtherOperativesConfiguration
    let accounts: [AccountEntity]
}
