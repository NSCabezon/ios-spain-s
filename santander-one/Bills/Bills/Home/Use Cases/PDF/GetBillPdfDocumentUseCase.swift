import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetBillPdfDocumentUseCase: UseCase<GetBillPdfDocumentUseCaseInput, GetBillPdfDocumentUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetBillPdfDocumentUseCaseInput) throws -> UseCaseResponse<GetBillPdfDocumentUseCaseOkOutput, StringErrorOutput> {
        let accountDTO = requestValues.account.dto
        let billDTO = requestValues.bill.dto
        var enableBillAndTaxesRemedy: Bool {
            let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
            return appConfigRepository.getBool(BillsConstants.enableBillAndTaxesRemedy) ?? false
        }
        
        let response = try self.provider
            .getBsanBillTaxesManager()
            .downloadPdfBill(account: accountDTO,
                             bill: billDTO,
                             enableBillAndTaxesRemedy: enableBillAndTaxesRemedy)
       
        guard response.isSuccess(),
            let documentDTO = try response.getResponseData(),
            let document = documentDTO.document else {
            let error = try response.getErrorMessage()
            return .error(StringErrorOutput(error))
        }
        
        guard let data = Data(base64Encoded: document) else {
            return .error(StringErrorOutput(nil))
        }
        
        return .ok(GetBillPdfDocumentUseCaseOkOutput(document: data))
    }
}

struct GetBillPdfDocumentUseCaseInput {
    let account: AccountEntity
    let bill: LastBillEntity
}

struct GetBillPdfDocumentUseCaseOkOutput {
    let document: Data
}
