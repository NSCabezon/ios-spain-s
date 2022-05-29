import SANLegacyLibrary
import CoreFoundationLib

class GetBillAndTaxesDetailUseCase: UseCase<GetBillAndTaxesDetailUseCaseInput, GetBillAndTaxesDetailUseCaseOkOutput, GetBillAndTaxesDetailUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver

    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetBillAndTaxesDetailUseCaseInput) throws -> UseCaseResponse<GetBillAndTaxesDetailUseCaseOkOutput, GetBillAndTaxesDetailUseCaseErrorOutput> {
        
        let bsanBillManager = provider.getBsanBillTaxesManager()
        let billDTO = requestValues.bill.billDTO
        let accountDTO = requestValues.account.accountDTO
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let enableBillAndTaxesRemedy = appConfigRepository.getBool(BillsConstants.enableBillAndTaxesRemedy) ?? false
        let response = try bsanBillManager.billAndTaxesDetail(of: accountDTO,
                                                              bill: billDTO,
                                                              enableBillAndTaxesRemedy: enableBillAndTaxesRemedy)

        if response.isSuccess(), let detailDTO = try response.getResponseData() {
            let billDetail = BillDetail.create(detailDTO)
            return UseCaseResponse.ok(GetBillAndTaxesDetailUseCaseOkOutput(billDetail: billDetail))
        }
        
        let errorMessage = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetBillAndTaxesDetailUseCaseErrorOutput(errorMessage))
    }
}

// MARK: - Input
struct GetBillAndTaxesDetailUseCaseInput {
    let bill: Bill
    let account: Account
}

// MARK: - OK Output
struct GetBillAndTaxesDetailUseCaseOkOutput {
    let billDetail: BillDetail
}

// MARK: - Error output
class GetBillAndTaxesDetailUseCaseErrorOutput: StringErrorOutput {
    override init(_ errorDesc: String?) {
        super.init(errorDesc)
    }
}
