import Foundation
import CoreFoundationLib
import SANLegacyLibrary

/// Call to all repositories to get every current persisted entity
class SetupPublicFilesUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let appConfigRepository: AppConfigRepository
    private let publicProductsRepository: PublicProductsRepository
    private let segmentedUsersRepository: SegmentedUserRepository
    private let faqsRepository: FaqsRepository
    private let rulesRepository: RulesRepository
    private let offersRepository: OffersRepository
    private let servicesForYouRepository: ServicesForYouRepository
    private let sepaInfoRepository: SepaInfoRepository
    private let tricksRepository: TricksRepository
    
    init(appConfigRepository: AppConfigRepository,
         publicProductsRepository: PublicProductsRepository,
         segmentedUsersRepository: SegmentedUserRepository,
         faqsRepository: FaqsRepository,
         rulesRepository: RulesRepository,
         offersRepository: OffersRepository,
         servicesForYouRepository: ServicesForYouRepository,
         sepaInfoRepository: SepaInfoRepository,
         tricksRepository: TricksRepository) {
        self.appConfigRepository = appConfigRepository
        self.publicProductsRepository = publicProductsRepository
        self.segmentedUsersRepository = segmentedUsersRepository
        self.faqsRepository = faqsRepository
        self.rulesRepository = rulesRepository
        self.offersRepository = offersRepository
        self.servicesForYouRepository = servicesForYouRepository
        self.sepaInfoRepository = sepaInfoRepository
        self.tricksRepository = tricksRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        _ = appConfigRepository.get()
        _ = publicProductsRepository.get()
        _ = segmentedUsersRepository.getSegmentedUser()
        _ = faqsRepository.get()
        _ = rulesRepository.get()
        _ = offersRepository.get()
        _ = servicesForYouRepository.get()
        _ = sepaInfoRepository.get()
        _ = tricksRepository.get()
        return .ok()
    }
}
