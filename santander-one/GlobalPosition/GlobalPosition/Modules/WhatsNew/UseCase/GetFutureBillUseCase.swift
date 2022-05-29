import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class GetFutureBillUseCase: UseCase<GetFutureBillUseCaseInput, GetFutureBillUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    let provider: BSANManagersProvider
    
    struct Constans {
        static let numberOfElements = 5
        static let page = 0
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetFutureBillUseCaseInput) throws -> UseCaseResponse<GetFutureBillUseCaseOkOutput, StringErrorOutput> {
        let response = try self.provider.getBsanBillTaxesManager().loadFutureBills(
            account: requestValues.account.dto,
            status: "AUT",
            numberOfElements: Constans.numberOfElements,
            page: Constans.page
        )
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        let output = GetFutureBillUseCaseOkOutput(futureBills: data.billList)
        return .ok(output)
    }
}

struct GetFutureBillUseCaseInput {
    let account: AccountEntity
}

struct GetFutureBillUseCaseOkOutput {
    let futureBills: [AccountFutureBillRepresentable]
}
