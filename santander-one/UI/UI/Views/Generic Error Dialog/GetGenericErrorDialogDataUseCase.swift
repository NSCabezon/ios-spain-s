import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class GetGenericErrorDialogDataUseCase: UseCase<Void, GetGenericErrorDialogDataUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetGenericErrorDialogDataUseCaseOkOutput, StringErrorOutput> {
        guard let webUrl = URL(string: "https://www.bancosantander.es/es/particulares") else { return .error(StringErrorOutput(nil)) }
        let segmentedUserRepository = self.dependenciesResolver.resolve(for: SegmentedUserRepository.self)
        let bsanManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        guard
            let user = try? bsanManagersProvider.getBsanSessionManager().getUser().getResponseData(),
            let userSegment = try? bsanManagersProvider.getBsanUserSegmentManager().getUserSegment().getResponseData()
        else {
            let segmentedUserMatcher = SegmentedUserMatcher(isPB: false, repository: segmentedUserRepository)
            let segmentList = segmentedUserRepository.getSegmentedUserGeneric()
            let segment = segmentedUserMatcher.retrieveDefaultSegment(segmentedUser: segmentList)
            let phone = self.phoneForCommercialSegment(segment)
            return .ok(GetGenericErrorDialogDataUseCaseOkOutput(webUrl: webUrl, phone: phone))
        }
        let isPB = user.isPB
        let segmentedUserMatcher = SegmentedUserMatcher(isPB: isPB, repository: segmentedUserRepository)
        let bdp = userSegment.bdpSegment?.clientSegment?.segment
        let commercial = userSegment.commercialSegment?.clientSegment?.segment
        let segment = segmentedUserMatcher.retrieveUserSegment(bdpType: bdp, comCode: commercial)
        let phone = self.phoneForCommercialSegment(segment)
        return .ok(GetGenericErrorDialogDataUseCaseOkOutput(webUrl: webUrl, phone: phone))
    }
    
    private func phoneForCommercialSegment(_ segment: CommercialSegmentsDTO?) -> String {
        return segment?.contact.superlinea?.numbers.first ?? ""
    }
}

extension GetGenericErrorDialogDataUseCase: GetGenericErrorDialogDataUseCaseProtocol { }
