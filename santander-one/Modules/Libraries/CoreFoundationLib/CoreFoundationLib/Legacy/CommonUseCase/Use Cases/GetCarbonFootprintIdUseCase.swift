import CoreDomain

public protocol GetCarbonFootprintIdUseCaseProtocol: UseCase<Void, GetCarbonFootprintIdUseCaseOkOutput, StringErrorOutput> {}

struct Constans {
    static let realmId = "HuellaCarbono"
}

public struct GetCarbonFootprintIdUseCaseInput: CarbonFootprintIdInputRepresentable {
    public let realmId: String?
    
    public init(realmId: String) {
        self.realmId = realmId
    }
}

public struct GetCarbonFootprintIdUseCaseOkOutput {
    public let token: CarbonFootprintTokenRepresentable?

    public init(carbonFootprintTokenRepresentable: CarbonFootprintTokenRepresentable?) {
        self.token = carbonFootprintTokenRepresentable
    }
}

public class GetCarbonFootprintIdUseCase: UseCase<Void, GetCarbonFootprintIdUseCaseOkOutput, StringErrorOutput> {
    private let carbonFootprintRepository: CarbonFootprintRepository
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.carbonFootprintRepository = dependenciesResolver.resolve()
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCarbonFootprintIdUseCaseOkOutput, StringErrorOutput> {
        let input = GetCarbonFootprintIdUseCaseInput(realmId: Constans.realmId)
        let repository: CarbonFootprintRepository = dependenciesResolver.resolve()
        let response = try  repository.getCarbonFootprintIdentificationToken(input: input)
        switch response {
        case .success(let data):
            return UseCaseResponse.ok(GetCarbonFootprintIdUseCaseOkOutput(carbonFootprintTokenRepresentable: data))
        case .failure(let error):
            return UseCaseResponse.error(StringErrorOutput(error.localizedDescription))
        }
    }
}

extension GetCarbonFootprintIdUseCase: GetCarbonFootprintIdUseCaseProtocol {}
