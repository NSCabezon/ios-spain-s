import SANLegacyLibrary
import CoreFoundationLib


class PreSetupBillsAndTaxesUseCase: UseCase<PreSetupBillsAndTaxesUseCaseInput, PreSetupBillsAndTaxesUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    private let appConfigRepository: AppConfigRepository
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: PreSetupBillsAndTaxesUseCaseInput) throws -> UseCaseResponse<PreSetupBillsAndTaxesUseCaseOkOutput, StringErrorOutput> {
        let accounts: [Account]
        let accountNotVisibles: [Account]
        if requestValues.account == nil {
            //GlobalPositionWrapper & UserPrefs
            let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
            guard let pgWrapper = merger.globalPositionWrapper else {
                return .error(StringErrorOutput(nil))
            }
            let accountList = pgWrapper.getAccountsVisiblesWithoutPiggy
            let accountListNotVisible = pgWrapper.getAccountsNotVisiblesWithoutPiggy
            guard accountList.count > 0 else {
                return .error(StringErrorOutput("receiptsAndTaxes_alert_needAccount"))
            }
            accounts = accountList
            accountNotVisibles = accountListNotVisible
        } else {
            accounts = []
            accountNotVisibles = []
        }
        let faqsRepository: FaqsRepositoryProtocol = self.dependenciesResolver.resolve()
        let faqs = faqsRepository.getFaqsList()?.billPaymentOperative?.compactMap {
            return FaqsEntity($0)
        }

        return .ok(PreSetupBillsAndTaxesUseCaseOkOutput(accounts: accounts, accountNotVisibles: accountNotVisibles, faqs: faqs))
    }
}

struct PreSetupBillsAndTaxesUseCaseInput {
    let account: Account?
}

struct PreSetupBillsAndTaxesUseCaseOkOutput {
    let accounts: [Account]
    let accountNotVisibles: [Account]?
    let faqs: [FaqsEntity]?
}
