import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetScheduledTransferDetailUseCase: UseCase<GetScheduledTransferDetailUseCaseInput, GetScheduledTransferDetailUseCaseOkOutput, GetScheduledTransferDetailUseCaseErrorOutput> {

    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetScheduledTransferDetailUseCaseInput) throws -> UseCaseResponse<GetScheduledTransferDetailUseCaseOkOutput, GetScheduledTransferDetailUseCaseErrorOutput> {
        guard let transferScheduledDTO = requestValues.transfer?.transferDTO else {
            let error = GetScheduledTransferDetailUseCaseErrorOutput("")
            return .error(error)
        }
        let accountDTO = requestValues.account.dto
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let sepaRepository = self.dependenciesResolver.resolve(for: SepaInfoRepositoryProtocol.self)
        let transferManager = provider.getBsanTransfersManager()
        let response = try transferManager.getScheduledTransferDetail(account: accountDTO,
                                                                      transferScheduledDTO: transferScheduledDTO)
        if response.isSuccess() {
            let result: ScheduledTransferDetailEntity?
            if let data = try response.getResponseData() {
                result = ScheduledTransferDetailEntity(dto: data)
            } else {
                result = nil
            }
            let sepaListDTO = sepaRepository.getSepaList()
            let sepaList = SepaInfoListEntity(dto: sepaListDTO)
            guard sepaList.allCurrencies.count > 0, sepaList.allCurrencies.count > 0 else {
                return .error(GetScheduledTransferDetailUseCaseErrorOutput(nil))
            }
            return .ok(GetScheduledTransferDetailUseCaseOkOutput(scheduledTransferDetail: result, sepaList: sepaList))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(GetScheduledTransferDetailUseCaseErrorOutput(errorDescription))
        }
    }
}

struct GetScheduledTransferDetailUseCaseOkOutput {
    let scheduledTransferDetail: ScheduledTransferDetailEntity?
    let sepaList: SepaInfoListEntity
}

class GetScheduledTransferDetailUseCaseErrorOutput: StringErrorOutput { }
