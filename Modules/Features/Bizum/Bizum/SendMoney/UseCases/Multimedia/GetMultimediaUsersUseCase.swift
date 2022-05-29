import Foundation
import CoreFoundationLib
import SANLibraryV3

struct GetMultimediaUsersInputUseCase {
    let checkPayment: BizumCheckPaymentEntity
    let contacts: [String]
}

struct GetMultimediaUsersUseCaseOutput {
    let multimediaContactsEntity: BizumGetMultimediaContactsEntity
}

final class GetMultimediaUsersUseCase: UseCase<GetMultimediaUsersInputUseCase, GetMultimediaUsersUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override func executeUseCase(requestValues: GetMultimediaUsersInputUseCase) throws -> UseCaseResponse<GetMultimediaUsersUseCaseOutput, StringErrorOutput> {
        let response = try self.provider.getBSANBizumManager().getMultimediaUsers(generateInput(requestValues))
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        let output = GetMultimediaUsersUseCaseOutput(multimediaContactsEntity: BizumGetMultimediaContactsEntity(dto))
        return .ok(output)
    }
}

private extension GetMultimediaUsersUseCase {
    func generateInput(_ input: GetMultimediaUsersInputUseCase) -> BizymMultimediaUsersInputParams {
        return BizymMultimediaUsersInputParams(checkPayment: input.checkPayment.dto,
                                               contactList: input.contacts)
    }
}
