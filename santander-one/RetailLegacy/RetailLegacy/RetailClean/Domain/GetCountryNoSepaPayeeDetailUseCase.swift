import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetNoSepaPayeeDetailUseCase: UseCase<GetNoSepaPayeeDetailUseCaseInput, GetNoSepaPayeeDetailUseCaseOkOutput, GetNoSepaPayeeDetailUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    var canceled: Bool = false
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetNoSepaPayeeDetailUseCaseInput) throws -> UseCaseResponse<GetNoSepaPayeeDetailUseCaseOkOutput, GetNoSepaPayeeDetailUseCaseErrorOutput> {
        let favorite = requestValues.favourite.representable
        let transferManager = provider.getBsanTransfersManager()
        let response = try transferManager.noSepaPayeeDetail(of: favorite.payeeAlias ?? "", recipientType: favorite.recipientType ?? "")
        if response.isSuccess(),
           !canceled,
           let noSepaPayeeDetailDTO = try response.getResponseData(),
           let noSepaPayee = noSepaPayeeDetailDTO.payee.flatMap(NoSepaPayee.create) {
            return .ok(GetNoSepaPayeeDetailUseCaseOkOutput(payee: noSepaPayee))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return .error(GetNoSepaPayeeDetailUseCaseErrorOutput(errorDescription))
    }
}

struct GetNoSepaPayeeDetailUseCaseInput {
    let favourite: Favourite
}

struct GetNoSepaPayeeDetailUseCaseOkOutput {
    let payee: NoSepaPayee
}

class GetNoSepaPayeeDetailUseCaseErrorOutput: StringErrorOutput {}

extension GetNoSepaPayeeDetailUseCase: Cancelable {
    func cancel() {
        canceled = true
    }
}
