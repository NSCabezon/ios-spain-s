import CoreFoundationLib

protocol GetAccountOtherOperativesUseCaseProtocol: UseCase<GetAccountOtherOperativesUseCaseInput, GetOtherOperativesUseCaseOkOutput, StringErrorOutput> { }

final class GetAccountOtherOperativesUseCase: UseCase<GetAccountOtherOperativesUseCaseInput, GetOtherOperativesUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAccountOtherOperativesUseCaseInput) throws -> UseCaseResponse<GetOtherOperativesUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let configuration = OtherOperativesConfiguration(account: requestValues.account)
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

struct GetAccountOtherOperativesUseCaseInput {
    let account: AccountEntity
    let locations: [PullOfferLocation]
}

extension GetAccountOtherOperativesUseCase: GetAccountOtherOperativesUseCaseProtocol { }
