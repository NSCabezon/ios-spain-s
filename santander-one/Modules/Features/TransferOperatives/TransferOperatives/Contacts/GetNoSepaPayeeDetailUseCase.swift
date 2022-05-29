import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import Foundation

public final class GetNoSepaPayeeDetailUseCase: UseCase<GetNoSepaPayeeDetailUseCaseInput, GetNoSepaPayeeDetailUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: GetNoSepaPayeeDetailUseCaseInput) throws -> UseCaseResponse<GetNoSepaPayeeDetailUseCaseOkOutput, StringErrorOutput> {
        let bsanManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let favorite = requestValues.favorite
        let transferManager = bsanManagersProvider.getBsanTransfersManager()
        let response = try transferManager.noSepaPayeeDetail(of: favorite.payeeAlias ?? "", recipientType: favorite.recipientType ?? "")
        if response.isSuccess(), let noSepaPayeeDetailDTO = try response.getResponseData(), let noSepaPayee = noSepaPayeeDetailDTO.payee.flatMap(NoSepaPayeeEntity.init) {
            return .ok(GetNoSepaPayeeDetailUseCaseOkOutput(payee: noSepaPayee))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return .error(StringErrorOutput(errorDescription))
    }
}

public struct GetNoSepaPayeeDetailUseCaseInput {
    let favorite: PayeeRepresentable
}

public struct GetNoSepaPayeeDetailUseCaseOkOutput {
    let payee: NoSepaPayeeEntity
}
