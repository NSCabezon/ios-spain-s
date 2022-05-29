import CoreFoundationLib
import SANLegacyLibrary

class PreSetupCreateUsualTransferUseCase: UseCase<Void, PreSetupCreateUsualTransferUseCaseOkOutput, StringErrorOutput> {
    private let sepaRepository: SepaInfoRepository

    init(sepaRepository: SepaInfoRepository) {
        self.sepaRepository = sepaRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupCreateUsualTransferUseCaseOkOutput, StringErrorOutput> {
        let sepaListDTO = sepaRepository.get()
        let sepaInfoList = SepaInfoList(dto: sepaListDTO)
        let sepaList: SepaInfoList = SepaInfoList(allCurrencies: sepaInfoList.allCurrencies, allCountries: sepaInfoList.allCountries)
        
        return .ok(PreSetupCreateUsualTransferUseCaseOkOutput(sepaList: sepaList))
    }
}

struct PreSetupCreateUsualTransferUseCaseOkOutput {
    let sepaList: SepaInfoList
}
