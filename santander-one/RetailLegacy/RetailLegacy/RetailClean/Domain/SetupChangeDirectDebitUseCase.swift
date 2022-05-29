import SANLegacyLibrary
import CoreFoundationLib


class SetupChangeDirectDebitUseCase: SetupUseCase<SetupChangeDirectDebitUseCaseInput, SetupChangeDirectDebitUseCaseOKOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository) {
        self.provider = managersProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupChangeDirectDebitUseCaseInput) throws -> UseCaseResponse<SetupChangeDirectDebitUseCaseOKOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let bill = requestValues.bill
        let ibanDTO = IBANDTO(ibanString: bill.linkedAccount)
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: ibanDTO)
        guard accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData()  else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let account = Account(dto: accountDTO)
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let pgWrapper = merger.globalPositionWrapper else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let accounts = pgWrapper.accounts.getVisibles().filter { $0 != account }
        guard accounts.count > 0 else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(SetupChangeDirectDebitUseCaseOKOutput(accounts: accounts, operativeConfig: operativeConfig))
    }
}

struct SetupChangeDirectDebitUseCaseInput {
    let bill: Bill
}

struct SetupChangeDirectDebitUseCaseOKOutput {
    let accounts: [Account]
    var operativeConfig: OperativeConfig
}

extension SetupChangeDirectDebitUseCaseOKOutput: SetupUseCaseOkOutputProtocol {}
extension SetupChangeDirectDebitUseCase: AssociatedAccountRetriever {}
