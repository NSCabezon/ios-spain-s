import CoreFoundationLib
import SANLibraryV3

final class GetContactListUseCase: UseCase<GetContactListUseCaseInput, GetContactListUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetContactListUseCaseInput) throws -> UseCaseResponse<GetContactListUseCaseOkOutput, StringErrorOutput> {
        let bizumConfiguration: BizumCheckPaymentConfiguration = self.dependenciesResolver.resolve(for: BizumCheckPaymentConfiguration.self)
        let response = try self.provider.getBSANBizumManager().getContacts(BizumGetContactsInputParams(checkPayment: bizumConfiguration.bizumCheckPaymentEntity.dto, contactList: requestValues.contactList))
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        let entity = BizumContactListEntity(dto)
        return .ok(GetContactListUseCaseOkOutput(bizumContactList: entity))
    }
}

struct GetContactListUseCaseInput {
    let contactList: [String]
}

struct GetContactListUseCaseOkOutput {
    let bizumContactList: BizumContactListEntity
}
