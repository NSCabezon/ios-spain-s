import CoreFoundationLib
import SANLegacyLibrary

class SetupReemittedNoSepaTransferCardUseCase: SetupUseCase<SetupReemittedNoSepaTransferCardUseCaseInput, SetupReemittedNoSepaTransferCardUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let sepaRepository: SepaInfoRepository
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    private let dependenciesResolver: DependenciesResolver
    private var bankingUtils: BankingUtilsProtocol {
        return dependenciesResolver.resolve()
    }
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, sepaRepository: SepaInfoRepository, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.sepaRepository = sepaRepository
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.dependenciesResolver = dependenciesResolver
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupReemittedNoSepaTransferCardUseCaseInput) throws -> UseCaseResponse<SetupReemittedNoSepaTransferCardUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let pgWrapper = merger.globalPositionWrapper else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let sepaListDTO = sepaRepository.get()
        let sepaList: SepaInfoList = SepaInfoList(dto: sepaListDTO)
        guard let account = requestValues.transferDetail.payee?.paymentAccountDescription, let countryCode = requestValues.transferDetail.destinationCountryCode else {
            return .ok(SetupReemittedNoSepaTransferCardUseCaseOkOutput(operativeConfig: operativeConfig, isDestinationSepaAccount: false, sepaList: sepaList, payer: pgWrapper.name.camelCasedString))
        }
        let country = sepaListDTO?.allCountries.first {
            $0.code == countryCode
        }
        guard country?.sepa == true && bankingUtils.isValidIban(ibanString: account) else {
            return .ok(SetupReemittedNoSepaTransferCardUseCaseOkOutput(operativeConfig: operativeConfig, isDestinationSepaAccount: false, sepaList: sepaList, payer: pgWrapper.name.camelCasedString))
        }
        return .ok(SetupReemittedNoSepaTransferCardUseCaseOkOutput(operativeConfig: operativeConfig, isDestinationSepaAccount: true, sepaList: sepaList, payer: pgWrapper.name.camelCasedString))
    }
}

struct SetupReemittedNoSepaTransferCardUseCaseInput {
    let transferDetail: BaseNoSepaPayeeDetailProtocol
}

struct SetupReemittedNoSepaTransferCardUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    let isDestinationSepaAccount: Bool
    let sepaList: SepaInfoList
    let payer: String
}

extension SetupReemittedNoSepaTransferCardUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}
