import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class NoSepaPayeeDetailUseCase: UseCase<NoSepaPayeeDetailUseCaseInput, NoSepaPayeeDetailUseCaseOkOutput, NoSepaPayeeDetailUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: NoSepaPayeeDetailUseCaseInput) throws -> UseCaseResponse<NoSepaPayeeDetailUseCaseOkOutput, NoSepaPayeeDetailUseCaseErrorOutput> {
        let favorite = requestValues.favourite.representable
        let transferManager = provider.getBsanTransfersManager()
        let response = try transferManager.noSepaPayeeDetail(of: favorite.payeeAlias ?? "", recipientType: favorite.recipientType ?? "")
        if response.isSuccess(), let noSepaPayeeDetailDTO = try response.getResponseData() {
            return .ok(NoSepaPayeeDetailUseCaseOkOutput(noSepaPayeeDetail: NoSepaPayeeDetail.create(noSepaPayeeDetailDTO)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return .error(NoSepaPayeeDetailUseCaseErrorOutput(errorDescription))
    }
}

struct NoSepaPayeeDetailUseCaseInput {
    let favourite: Favourite
}

struct NoSepaPayeeDetailUseCaseOkOutput {
    let noSepaPayeeDetail: NoSepaPayeeDetail
}

class NoSepaPayeeDetailUseCaseErrorOutput: StringErrorOutput {}
