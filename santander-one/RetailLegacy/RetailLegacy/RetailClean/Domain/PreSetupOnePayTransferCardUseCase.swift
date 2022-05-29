import SANLegacyLibrary
import CoreFoundationLib
import Transfer
import TransferOperatives
import Account

class PreSetupOnePayTransferCardUseCase: UseCase<PreSetupOnePayTransferCardUseCaseInput, PreSetupOnePayTransferCardUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    private let sepaRepository: SepaInfoRepository
    private let appConfigRepository: AppConfigRepository
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, sepaRepository: SepaInfoRepository, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.sepaRepository = sepaRepository
        self.appConfigRepository = appConfigRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: PreSetupOnePayTransferCardUseCaseInput) throws -> UseCaseResponse<PreSetupOnePayTransferCardUseCaseOkOutput, StringErrorOutput> {
        let sepaListDTO = sepaRepository.get()
        let sepaList: SepaInfoList = SepaInfoList(dto: sepaListDTO)
        guard sepaList.allCurrencies.count > 0 else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let pgWrapper = merger.globalPositionWrapper else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let allAccounts = getAccounts(pgWrapper.getAllAccountsWithoutPiggy)
        var accountList = getAccounts(pgWrapper.getAccountsVisiblesWithoutPiggy)
        var accountListNotVisibles = getAccounts(pgWrapper.getAccountsNotVisiblesWithoutPiggy)
        if let accountModifier = self.dependenciesResolver.resolve(forOptionalType: AccountModifierProtocol.self),
           accountModifier.filteringBySituationType == true {
            accountList = self.filterBySituationType(accounts: accountList)
            accountListNotVisibles = self.filterBySituationType(accounts: accountListNotVisibles)
        }
        guard allAccounts.count > 0 else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let faqsRepository: FaqsRepositoryProtocol = self.dependenciesResolver.resolve()
        let faqs = faqsRepository.getFaqsList()?.transferOperative?.compactMap {
            return FaqsEntity($0)
        }
        return UseCaseResponse.ok(PreSetupOnePayTransferCardUseCaseOkOutput(accountVisibles: accountList, accountNotVisibles: accountListNotVisibles, sepaList: sepaList, faqs: faqs))
    }
}

private extension PreSetupOnePayTransferCardUseCase {
    func getAccounts(_ accounts: [Account]) -> [Account] {
        guard let onePayTransferModifier = self.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) else { return accounts }
        return accounts.filter{onePayTransferModifier.accountCondition($0.accountEntity)}
    }
    
    func filterBySituationType(accounts: [Account]) -> [Account] {
        let filteredAccounts = accounts.filter { account in
            account.accountEntity.situationType != "Saving Account"
        }
        return filteredAccounts
    }
}

struct PreSetupOnePayTransferCardUseCaseInput {
    let account: Account?
}

struct PreSetupOnePayTransferCardUseCaseOkOutput {
    let accountVisibles: [Account]
    let accountNotVisibles: [Account]
    let sepaList: SepaInfoList
    let faqs: [FaqsEntity]?
}
