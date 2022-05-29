import CoreDomain
import SANLegacyLibrary

final class MetricsLogInUserUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let tealiumRepository: TealiumRepository
    private let netInsightRepository: NetInsightRepository
    private let bsanManagersProvider: BSANManagersProvider

    init(dependenciesResolver: DependenciesResolver) {
        self.tealiumRepository = dependenciesResolver.resolve()
        self.netInsightRepository = dependenciesResolver.resolve()
        self.bsanManagersProvider = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let userSegmentResponse = try bsanManagersProvider.getBsanUserSegmentManager().getUserSegment()
        if userSegmentResponse.isSuccess(), let userSegmentDTO = try userSegmentResponse.getResponseData() {
            tealiumRepository.setSegment(comercial: userSegmentDTO.commercialSegment?.clientSegment?.segment, bdp: userSegmentDTO.bdpSegment?.clientSegment?.segment)
        }
        let userIdResponse = try bsanManagersProvider.getBsanPGManager().getGlobalPosition()
        guard userIdResponse.isSuccess(), let globalPositionDTO = try userIdResponse.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        tealiumRepository.setUser(personCode: globalPositionDTO.userDataDTO?.clientPersonCode ?? "", personType: globalPositionDTO.userDataDTO?.clientPersonType ?? "")
        netInsightRepository.setUser(personCode: globalPositionDTO.userDataDTO?.clientPersonCode ?? "", personType: globalPositionDTO.userDataDTO?.clientPersonType ?? "")
        return .ok()
    }
}
