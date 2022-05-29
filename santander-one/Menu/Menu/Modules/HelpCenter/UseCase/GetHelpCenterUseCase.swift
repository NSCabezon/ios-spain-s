import CoreFoundationLib
import Foundation
import SANLegacyLibrary

final class GetHelpCenterUseCase: UseCase<Void, GetHelpCenterUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let accountDescriptorRepository: AccountDescriptorRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.accountDescriptorRepository = self.dependenciesResolver.resolve(for: AccountDescriptorRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetHelpCenterUseCaseOkOutput, StringErrorOutput> {
        let faqsEntity = getFaqsRepository()
        let commercialSegment = getCommercialSegment()
        let helpCenterTips = getHelpCenterTips()
        let enabledVirtualAssistant = self.enableVirtualAssistant
        let url = self.virtualAssistantUrl
        let closeUrl = self.virtualAssistantCloseUrl
        let enableChatInbenta = self.enableChatInbenta
        return .ok(
            GetHelpCenterUseCaseOkOutput(
                faqsEntity: faqsEntity,
                commercialSegment: commercialSegment,
                helpCenterTips: helpCenterTips,
                enableVirtualAssistant: enabledVirtualAssistant,
                virtualAssistantUrl: url,
                virtualAssistantCloseUrl: closeUrl,
                enableChatInbenta: enableChatInbenta,
                hasVipPlanProducts: hasVipPlanProducts,
                isUserSmart: isUserSmart,
                isUserSPB: isUserPB,
                isUserSelect: isUserSelect)
        )
    }
}

extension GetHelpCenterUseCase: OneProductsEvaluator {}

private extension GetHelpCenterUseCase {
    var enableVirtualAssistant: Bool {
        return appConfigRepository.getBool("enableVirtualAssistant") ?? false
    }
    
    var virtualAssistantUrl: String {
        return appConfigRepository.getString("virtualAssistantUrl") ?? ""
    }
    
    var virtualAssistantCloseUrl: String {
        return appConfigRepository.getString("virtualAssistantCloseUrl") ?? ""
    }
    
    var isAppconfigInbentaEnabled: Bool {
        return self.appConfigRepository.getBool("enableChatInbenta") == true
    }
    
    var enableChatInbenta: Bool {
        return self.isAppconfigInbentaEnabled &&
            ((self.isUserPB || self.isUserSelect || self.isUserSmart) || hasChatOneProducts)
    }
    
    var isUserSelect: Bool {
        return (try? userSegmentManager.isSelectUser()) ?? false
    }
    
    var isUserSmart: Bool {
        return (try? userSegmentManager.isSmartUser()) ?? false
    }
    
    var userSegmentManager: BSANUserSegmentManager {
        return self.provider.getBsanUserSegmentManager()
    }
    
    var isUserPB: Bool {
        return self.globalPosition.isPb == true
    }
    
    var globalPosition: GlobalPositionRepresentable {
        return self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
    }
    
    var hasChatOneProducts: Bool {
        return hasOneProducts(accountDescriptorRepository: accountDescriptorRepository, bsanManagersProvider: provider, for: \.chatProducts)
    }
    
    var hasVipPlanProducts: Bool {
        return hasOneProducts(accountDescriptorRepository: accountDescriptorRepository, bsanManagersProvider: provider, for: \.vipOneProducts)
    }
    
    func getFaqsRepository() -> [FaqsEntity] {
        let faqsRepository = dependenciesResolver.resolve(for: FaqsRepositoryProtocol.self)
        guard let faqsListDTO = faqsRepository.getFaqsList() else { return [] }
        return faqsListDTO.helpCenter?.map { FaqsEntity($0) } ?? []
    }
    
    func getHelpCenterTips() -> [PullOfferTipEntity]? {
        guard let helpCenterTips = try? checkRepositoryResponse(appRepository.getHelpCenterTips()) ?? nil else {
            return nil
        }
        helpCenterTips.forEach { $0.offer = containtOffer(forTip: $0) }
        return helpCenterTips
    }
    
    // MARK: - Pull offer request
    func containtOffer(forTip tip: PullOfferTipEntity) -> OfferEntity? {
        let pullOfferInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        guard let offerId = tip.offerId, let offerDTO = pullOfferInterpreter.getOffer(offerId: offerId) else {
            return nil
        }
        return OfferEntity(offerDTO)
    }
    
    // MARK: - Segmented user
    func getCommercialSegment() -> CommercialSegmentEntity? {
        guard let commercialSegment = try? checkRepositoryResponse(appRepository.getCommercialSegment()) ?? nil else {
            return nil
        }
        return commercialSegment
    }
}

struct GetHelpCenterUseCaseOkOutput {
    let faqsEntity: [FaqsEntity]?
    let commercialSegment: CommercialSegmentEntity?
    let helpCenterTips: [PullOfferTipEntity]?
    let enableVirtualAssistant: Bool?
    let virtualAssistantUrl: String?
    let virtualAssistantCloseUrl: String?
    let enableChatInbenta: Bool
    let hasVipPlanProducts: Bool
    let isUserSmart: Bool
    let isUserSPB: Bool
    let isUserSelect: Bool
}
