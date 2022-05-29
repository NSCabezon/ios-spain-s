import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class SetupModifyDeferredTransferUseCase: SetupUseCase<SetupModifyDeferredTransferUseCaseInput, SetupModifyDeferredTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let sepaRepository: SepaInfoRepository
    
    init(appConfigRepository: AppConfigRepository, sepaRepository: SepaInfoRepository) {
        self.sepaRepository = sepaRepository
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupModifyDeferredTransferUseCaseInput) throws -> UseCaseResponse<SetupModifyDeferredTransferUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let sepaListDTO = sepaRepository.get()
        let sepaList = SepaInfoList(dto: sepaListDTO)
        
        let country = sepaList.getSepaCountryInfo(requestValues.scheduledTransferDetail.beneficiary?.countryCode)
        let currency = sepaList.getSepaCurrencyInfo(requestValues.scheduledTransfer.amount?.currency?.currencyName)
        
        return UseCaseResponse.ok(SetupModifyDeferredTransferUseCaseOkOutput(operativeConfig: operativeConfig, country: country, currency: currency))
    }
}

struct SetupModifyDeferredTransferUseCaseInput {
    let scheduledTransferDetail: ScheduledTransferDetail
    let scheduledTransfer: TransferScheduled
}

struct SetupModifyDeferredTransferUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
    let country: SepaCountryInfo
    let currency: SepaCurrencyInfo
}
