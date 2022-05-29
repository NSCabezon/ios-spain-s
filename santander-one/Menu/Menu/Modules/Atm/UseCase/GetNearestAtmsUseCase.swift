import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetNearestAtmsUseCase: UseCase<GetNearestAtmsUseCaseInput, GetNearestAtmsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appRepository: AppRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: GetNearestAtmsUseCaseInput) throws -> UseCaseResponse<GetNearestAtmsUseCaseOkOutput, StringErrorOutput> {
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = provider.getBsanBranchLocatorManager()
        let input = BranchLocatorATMParameters(
            lat: requestValues.latitude,
            lon: requestValues.longitude,
            customer: false,
            country: Country.es
        )
        let nearestAtmsLimit = appConfigRepository.getString("nearestAtmsLimit").flatMap { Int($0) } ?? 10
        let response = try manager.getNearATMs(input)
        guard response.isSuccess(), let atmDtosList = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        let atmDtosListLimit = Array(atmDtosList.prefix(nearestAtmsLimit))
        let enrichedInput = BranchLocatorEnrichedATMParameters(branches: atmDtosListLimit)
        guard let enrichedResponse = try? manager.getEnrichedATM(enrichedInput), enrichedResponse.isSuccess(),
            let enrichedDtosList = try? enrichedResponse.getResponseData() else {
                let nearestAtms = atmDtosListLimit.map({ AtmEntity(dto: $0, enrichedDto: nil) })
                return .ok(GetNearestAtmsUseCaseOkOutput(nearetsAtms: nearestAtms, isEnrichedATMServiceAvailable: false))
        }
        let nearestAtms = atmDtosListLimit.map { atmDto in
            AtmEntity(dto: atmDto, enrichedDto: enrichedDtosList.first(where: { $0.code == atmDto.code }))
        }
        return .ok(GetNearestAtmsUseCaseOkOutput(nearetsAtms: nearestAtms, isEnrichedATMServiceAvailable: true))
    }
}

struct GetNearestAtmsUseCaseInput {
    let latitude: Double
    let longitude: Double
}

struct GetNearestAtmsUseCaseOkOutput {
    let nearetsAtms: [AtmEntity]
    let isEnrichedATMServiceAvailable: Bool
}
