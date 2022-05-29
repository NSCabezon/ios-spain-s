import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class PreSetupSignUpCesCardUseCase: UseCase<Void, PreSetupSignUpCesCardUseCaseOkOutput, StringErrorOutput> {
    
    private let appConfig: AppConfigRepository
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let appConfigRepository: AppConfigRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    private let bsanManagersProvider: BSANManagersProvider
    
    init(appConfig: AppConfigRepository, bsanManagerProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository, bsanManagersProvider: BSANManagersProvider) {
        self.provider = bsanManagerProvider
        self.appConfig = appConfig
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
        self.bsanManagersProvider = bsanManagersProvider
        super.init()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupSignUpCesCardUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        let cmps = CMPS.createFromDTO(dto: try checkRepositoryResponse(try bsanManagersProvider.getBsanSendMoneyManager().getCMPSStatus()))
        let isOTPExcepted = cmps.isOTPExcepted
        
        guard let globalPositionWrapper = merger.globalPositionWrapper, isOTPExcepted == false else {
            return .error(StringErrorOutput(nil))
        }
        
        let cards = globalPositionWrapper.cards.getVisibles().filter({
            $0.isActive && $0.isContractActive && !$0.isPrepaidCard
        })
        guard cards.count > 0 else {
            return .error(StringErrorOutput("deeplink_alert_errorCes"))
        }
        return .ok(PreSetupSignUpCesCardUseCaseOkOutput(cards: cards))
    }
}

struct PreSetupSignUpCesCardUseCaseOkOutput {
    let cards: [Card]
}
