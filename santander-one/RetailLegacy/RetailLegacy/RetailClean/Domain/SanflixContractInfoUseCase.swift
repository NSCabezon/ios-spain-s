import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class SanflixContractInfoUseCase: UseCase<SanflixContractInfoUseCaseInput, SanflixContractInfoUseCaseOkOutput, StringErrorOutput> {
    
    private let appConfigRepository: AppConfigRepository
    private let bsanManagersProvider: BSANManagersProvider
    private let pullOffersInterpreter: PullOffersInterpreter
    
    init(appConfigRepository: AppConfigRepository, bsanManagersProvider: BSANManagersProvider, pullOffersInterpreter: PullOffersInterpreter) {
        self.appConfigRepository = appConfigRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.pullOffersInterpreter = pullOffersInterpreter
    }
    
    override func executeUseCase(requestValues: SanflixContractInfoUseCaseInput) throws -> UseCaseResponse<SanflixContractInfoUseCaseOkOutput, StringErrorOutput> {
        let user: String? = try {
            guard let dto = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition()) else {
                return nil
            }
            let gp = GlobalPosition.createFrom(dto: dto)
            return gp.userId
        }()
        
        guard let userId = user else {
            return .error(PullOfferCandidatesUseCaseErrorOutput(nil))
        }
        var offerDTO: OfferDTO?
        if let location = requestValues.location {
            offerDTO = pullOffersInterpreter.getCandidate(userId: userId, location: location)
        }
        let sanflixOffer = offerDTO != nil ? OfferEntity(offerDTO!): nil
        let isSanflixEnabled = appConfigRepository.getBool(DomainConstant.appConfigEnableApplyBySanflix) ?? false
        return .ok(SanflixContractInfoUseCaseOkOutput(info: SanflixContractInfo(isEnabled: isSanflixEnabled, offer: sanflixOffer, location: requestValues.location)))
    }
}

struct SanflixContractInfoUseCaseInput {
    let location: PullOfferLocation?
}

struct SanflixContractInfoUseCaseOkOutput {
    let info: SanflixContractInfo
}
