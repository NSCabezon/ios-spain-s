import SANLegacyLibrary
import CoreFoundationLib

class SetupDuplicateBillUseCase: SetupUseCase<SetupDuplicateBillUseCaseInput, SetupDuplicateBillUseCaseOKOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(repository: AppConfigRepository, managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
        super.init(appConfigRepository: repository)
    }
    
    override func executeUseCase(requestValues: SetupDuplicateBillUseCaseInput) throws -> UseCaseResponse<SetupDuplicateBillUseCaseOKOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let bill = requestValues.bill
        let ibanDTO = IBANDTO(ibanString: bill.linkedAccount)
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: ibanDTO)
        guard accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData()  else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let account = Account(dto: accountDTO)
        let manager = provider.getBsanBillTaxesManager()
        var enableBillAndTaxesRemedy: Bool {
            return appConfigRepository.getBool(BillsConstants.enableBillAndTaxesRemedy) ?? false
        }
        let response = try manager.duplicateBill(account: accountDTO, bill: bill.billDTO, enableBillAndTaxesRemedy: enableBillAndTaxesRemedy)
        guard response.isSuccess(), let duplicateBillDTO = try response.getResponseData() else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        let duplicateBill = DuplicateBill(dto: duplicateBillDTO)
        return UseCaseResponse.ok(SetupDuplicateBillUseCaseOKOutput(account: account, duplicateBill: duplicateBill, operativeConfig: operativeConfig))
    }
}

struct SetupDuplicateBillUseCaseInput {
    let bill: Bill
}

struct SetupDuplicateBillUseCaseOKOutput {
    let account: Account
    let duplicateBill: DuplicateBill
    var operativeConfig: OperativeConfig
}

extension SetupDuplicateBillUseCaseOKOutput: SetupUseCaseOkOutputProtocol {}
extension SetupDuplicateBillUseCase: AssociatedAccountRetriever {}
