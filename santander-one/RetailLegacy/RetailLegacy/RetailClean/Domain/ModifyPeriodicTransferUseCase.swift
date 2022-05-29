import SANLegacyLibrary
import CoreFoundationLib

class ModifyPeriodicTransferUseCase: UseCase<ModifyPeriodicTransferUseCaseInput, ModifyPeriodicTransferUseCaseOkOutput, StringErrorOutput> {
    
    let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: ModifyPeriodicTransferUseCaseInput) throws -> UseCaseResponse<ModifyPeriodicTransferUseCaseOkOutput, StringErrorOutput> {
        
        let response = try bsanManagersProvider.getBsanTransfersManager().modifyPeriodicTransferDetail(originAccountDTO: requestValues.account.accountDTO, transferScheduledDTO: requestValues.scheduledTransfer.transferDTO, transferScheduledDetailDTO: requestValues.scheduledTransferDetail.transferDetailDTO)
        
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return .error(StringErrorOutput(try response.getErrorMessage()))
        }
        guard let signatureDTO = data.signatureDTO else {
            return .error(StringErrorOutput(try response.getErrorMessage()))
        }
        
        return .ok(ModifyPeriodicTransferUseCaseOkOutput(signature: Signature(dto: signatureDTO), modifyPeriodicTransfer: ModifyPeriodicTransfer(dto: data)))
    }
}
struct ModifyPeriodicTransferUseCaseInput {
    let account: Account
    let scheduledTransfer: TransferScheduled
    let scheduledTransferDetail: ScheduledTransferDetail
}

struct ModifyPeriodicTransferUseCaseOkOutput {
    let signature: Signature
    let modifyPeriodicTransfer: ModifyPeriodicTransfer
}

class ModifyPeriodicTransfer {
    
    private(set) var dto: ModifyPeriodicTransferDTO
    
    init(dto: ModifyPeriodicTransferDTO) {
        self.dto = dto
    }
    
    var signature: Signature? {
        get {
            guard let signatureDTO = dto.signatureDTO else { return nil }
            return Signature(dto: signatureDTO)
        }
        set {
            dto.signatureDTO = newValue?.dto
        }
    }
}
