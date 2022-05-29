import CoreFoundationLib
import Foundation

class PreSetupUpdateNoSepaUsualTransferUseCase: UseCase<Void, PreSetupUpdateNoSepaUsualTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let appConfigRepository: AppConfigRepository
    private let sepaRepository: SepaInfoRepository

    init(appConfigRepository: AppConfigRepository, sepaRepository: SepaInfoRepository) {
        self.appConfigRepository = appConfigRepository
        self.sepaRepository = sepaRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupUpdateNoSepaUsualTransferUseCaseOkOutput, StringErrorOutput> {
        let sepaListDTO = sepaRepository.get()
        let sepaInfoList = SepaInfoList(dto: sepaListDTO)
        let sepaList = SepaInfoList(allCurrencies: sepaInfoList.allCurrencies, allCountries: sepaInfoList.allCountries.filter { $0.sepa })
        let allCountries = sepaInfoList.allCountries
        
        return .ok(PreSetupUpdateNoSepaUsualTransferUseCaseOkOutput(sepaList: sepaList, allCountries: allCountries))
    }
}

struct PreSetupUpdateNoSepaUsualTransferUseCaseOkOutput {
    let sepaList: SepaInfoList
    let allCountries: [SepaCountryInfo]
}
