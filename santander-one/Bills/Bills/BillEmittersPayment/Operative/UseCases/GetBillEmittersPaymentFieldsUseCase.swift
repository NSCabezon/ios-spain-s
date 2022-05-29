import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetBillEmittersPaymentFieldsUseCase: UseCase<GetBillEmittersPaymentFieldsUseCaseInput, GetBillEmittersPaymentFieldsUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetBillEmittersPaymentFieldsUseCaseInput) throws -> UseCaseResponse<GetBillEmittersPaymentFieldsUseCaseOkOutput, StringErrorOutput> {
        let bsanManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let response = try bsanManagersProvider.getBsanBillTaxesManager().consultFormats(
            of: requestValues.account.dto,
            emitterCode: requestValues.emitterCode,
            productIdentifier: requestValues.productIdentifier,
            collectionTypeCode: requestValues.collectionTypeCode,
            collectionCode: requestValues.collectionCode
        )
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let error = StringErrorOutput(try? response.getErrorMessage())
            return .error(error)
        }
        return UseCaseResponse.ok(GetBillEmittersPaymentFieldsUseCaseOkOutput(formats: ConsultTaxCollectionFormatsEntity(data)))
    }
}

struct GetBillEmittersPaymentFieldsUseCaseInput {
    let account: AccountEntity
    let emitterCode: String
    let productIdentifier: String
    let collectionTypeCode: String
    let collectionCode: String
}

struct GetBillEmittersPaymentFieldsUseCaseOkOutput {
    let formats: ConsultTaxCollectionFormatsEntity
}
