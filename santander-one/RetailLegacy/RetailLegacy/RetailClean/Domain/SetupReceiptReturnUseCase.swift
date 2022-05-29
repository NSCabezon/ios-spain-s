import SANLegacyLibrary
import CoreFoundationLib

class SetupReceiptReturnUseCase: SetupUseCase<SetupReceiptReturnUseCaseInput, SetupReceiptReturnUseCaseOKOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(repository: AppConfigRepository, managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
        super.init(appConfigRepository: repository)
    }
    
    override func executeUseCase(requestValues: SetupReceiptReturnUseCaseInput) throws -> UseCaseResponse<SetupReceiptReturnUseCaseOKOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let bill = requestValues.bill
        let ibanDTO = IBANDTO(ibanString: bill.linkedAccount)
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: ibanDTO)
        guard accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData()  else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let bsanBillManager = provider.getBsanBillTaxesManager()
        let enableBillAndTaxesRemedy = appConfigRepository.getBool(BillsConstants.enableBillAndTaxesRemedy) ?? false
        let response = try bsanBillManager.billAndTaxesDetail(of: accountDTO, bill: bill.billDTO, enableBillAndTaxesRemedy: enableBillAndTaxesRemedy)
        guard response.isSuccess(), let detailDTO = try response.getResponseData() else {
            let errorMessage = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(GetBillAndTaxesDetailUseCaseErrorOutput(errorMessage))
        }
        let billDetail = BillDetail.create(detailDTO)
        let account = Account(dto: accountDTO)
        return UseCaseResponse.ok(SetupReceiptReturnUseCaseOKOutput(account: account, billDetail: billDetail, operativeConfig: operativeConfig))
    }
}

struct SetupReceiptReturnUseCaseInput {
    let bill: Bill
}

struct SetupReceiptReturnUseCaseOKOutput {
    let account: Account
    let billDetail: BillDetail
    var operativeConfig: OperativeConfig
}

extension SetupReceiptReturnUseCaseOKOutput: SetupUseCaseOkOutputProtocol {}
extension SetupReceiptReturnUseCase: AssociatedAccountRetriever {}
