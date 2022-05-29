import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetDetailBillUseCase: UseCase<GetDetailBillUseCaseInput, GetDetailBillUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetDetailBillUseCaseInput) throws -> UseCaseResponse<GetDetailBillUseCaseOkOutput, StringErrorOutput> {
        let accountDTO = requestValues.lastBillDetail.account.dto
        let billDTO = requestValues.lastBillDetail.bill.dto
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let enableBillAndTaxesRemedy = appConfigRepository.getBool(BillsConstants.enableBillAndTaxesRemedy) ?? false
        let response = try self.provider.getBsanBillTaxesManager().billAndTaxesDetail(of: accountDTO,
                                                                                      bill: billDTO,
                                                                                      enableBillAndTaxesRemedy: enableBillAndTaxesRemedy)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return .error(StringErrorOutput(try response.getErrorMessage() ?? nil))
        }
        let billDetail = LastBillDetailEntity(data)
        return UseCaseResponse.ok(GetDetailBillUseCaseOkOutput(billDetail: billDetail))
    }
}

struct GetDetailBillUseCaseInput {
    let lastBillDetail: LastBillDetail
}

struct GetDetailBillUseCaseOkOutput {
    let billDetail: LastBillDetailEntity
}
