import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetOtherOperativesUseCase: UseCase<GetOtherOperativesUseCaseInput, GetOtherOperativesUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetOtherOperativesUseCaseInput) throws -> UseCaseResponse<GetOtherOperativesUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let configuration = self.dependenciesResolver.resolve(for: OtherOperativesConfiguration.self)
        var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
        if let userId: String = globalPosition.userId {
            for location in requestValues.locations {
                if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                    outputCandidates[location] = OfferEntity(candidate, location: location)
                }
            }
        }
        let bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let cmpsResponse = try bsanManagersProvider.getBsanSendMoneyManager().getCMPSStatus()
        var otpExcepted: Bool = false
        
        if cmpsResponse.isSuccess(), let cmpsDTO = try cmpsResponse.getResponseData() {
            let cmps = CMPSEntity.createFromDTO(dto: cmpsDTO)
            otpExcepted = cmps.isOTPExcepted
        }
        
        return .ok(GetOtherOperativesUseCaseOkOutput(pullOfferCandidates: outputCandidates,
                                                     configuration: configuration,
                                                     isOTPExcepted: otpExcepted))
    }
}

struct GetOtherOperativesUseCaseInput {
    let locations: [PullOfferLocation]
}

struct GetOtherOperativesUseCaseOkOutput {
    let pullOfferCandidates: [PullOfferLocation: OfferEntity]
    let configuration: OtherOperativesConfiguration
    let isOTPExcepted: Bool
}
