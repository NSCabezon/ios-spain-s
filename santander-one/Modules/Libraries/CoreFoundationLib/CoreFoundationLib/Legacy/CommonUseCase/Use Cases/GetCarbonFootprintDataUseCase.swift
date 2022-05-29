import CoreDomain
import SANLegacyLibrary

public protocol GetCarbonFootprintDataUseCaseProtocol: UseCase<Void, GetCarbonFootprintDataUseCaseOkOutput, StringErrorOutput> {}

public struct GetCarbonFootprintDataUseCaseInput: CarbonFootprintDataInputRepresentable {
    public let firstName: String?
    public let lastName: String?
    public let contract: String?
    
    public init(firstName: String,
                lastName: String,
                contract: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.contract = contract
    }
}

public struct GetCarbonFootprintDataUseCaseOkOutput {
    public let token: CarbonFootprintTokenRepresentable?

    public init(carbonFootprintTokenRepresentable: CarbonFootprintTokenRepresentable?) {
        self.token = carbonFootprintTokenRepresentable
    }
}

public class GetCarbonFootprintDataUseCase: UseCase<Void, GetCarbonFootprintDataUseCaseOkOutput, StringErrorOutput> {
    private let carbonFootprintRepository: CarbonFootprintRepository
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.carbonFootprintRepository = dependenciesResolver.resolve()
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCarbonFootprintDataUseCaseOkOutput, StringErrorOutput> {
        let input = getCarbonFootprintDataUseCaseInput()
        let repository: CarbonFootprintRepository = dependenciesResolver.resolve()
        let response = try  repository.getCarbonFootprintDataToken(input: input)
        switch response {
        case .success(let data):
            return UseCaseResponse.ok(GetCarbonFootprintDataUseCaseOkOutput(carbonFootprintTokenRepresentable: data))
        case .failure(let error):
            return UseCaseResponse.error(StringErrorOutput(error.localizedDescription))
        }
    }
}

private extension GetCarbonFootprintDataUseCase {
    func getCarbonFootprintDataUseCaseInput() -> GetCarbonFootprintDataUseCaseInput {
        let managerProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let globalPosition = try? managerProvider.getBsanPGManager().getGlobalPosition()
        let responseData = try? globalPosition?.getResponseData()
        let firstName = responseData?.clientNameWithoutSurname ?? ""
        let lastName = responseData?.clientFirstSurname?.surname ?? ""
        let contract = responseData?.userDataDTO?.contract?.formattedValue ?? ""
        let input = GetCarbonFootprintDataUseCaseInput(
            firstName: firstName,
            lastName: lastName,
            contract: contract
        )
        return input
    }
}

extension GetCarbonFootprintDataUseCase: GetCarbonFootprintDataUseCaseProtocol {}
