import CoreFoundationLib
import Foundation

class PreSetupUpdateUsualTransferUseCase: UseCase<Void, PreSetupUpdateUsualTransferUseCaseOKOutput, StringErrorOutput> {
    
    private let sepaRepository: SepaInfoRepository
    
    init(sepaRepository: SepaInfoRepository) {
        self.sepaRepository = sepaRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupUpdateUsualTransferUseCaseOKOutput, StringErrorOutput> {
        let sepaListDTO = sepaRepository.get()
        let sepaInfoList = SepaInfoList(dto: sepaListDTO)
        let sepaList = SepaInfoList(allCurrencies: sepaInfoList.allCurrencies, allCountries: sepaInfoList.allCountries.filter({ $0.sepa }))
        return .ok(PreSetupUpdateUsualTransferUseCaseOKOutput(sepaList: sepaList))
    }
}

struct PreSetupUpdateUsualTransferUseCaseOKOutput {
    let sepaList: SepaInfoList
}
