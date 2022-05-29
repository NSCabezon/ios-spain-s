import CoreFoundationLib
import SANLegacyLibrary


class SetupOnePayTransferCardUseCase: SetupUseCase<Void, SetupOnePayTransferCardUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository) {
        self.provider = managersProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupOnePayTransferCardUseCaseOkOutput, StringErrorOutput> {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let pgWrapper = merger.globalPositionWrapper else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let userPrefEntity = appRepository.getUserPreferences(userId: pgWrapper.userId)
        let favoriteContacts = userPrefEntity.pgUserPrefDTO.favoriteContacts
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let dataUsualTransfer = try getUsualTransfers(loadingFromNetworkIfNeeded: true)
        let usualTransfers = dataUsualTransfer.map { Favourite.create($0) }
        let amount: Amount?
        if let max = appConfigRepository.getAppConfigDecimalNode(nodeName: DomainConstant.appConfigInstantNationalTransfersMaxAmount) {
            amount = Amount.createWith(value: max)
        } else {
            amount = nil
        }
        let baseUrl = try? self.appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase ?? ""
        let enabledFavouritesCarrusel = self.appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnabledFavouritesCarrusel) ?? false
        return UseCaseResponse.ok(SetupOnePayTransferCardUseCaseOkOutput(operativeConfig: operativeConfig, favouriteList: usualTransfers, maxAmount: amount, payer: pgWrapper.name.camelCasedString, baseUrl: baseUrl, enabledFavouritesCarrusel: enabledFavouritesCarrusel, favoriteContacts: favoriteContacts, summaryUserName: pgWrapper.fullName))
    }
    
    func getUsualTransfers(loadingFromNetworkIfNeeded loadingFromNetwork: Bool) throws -> [PayeeDTO] {
        let transferManager = provider.getBsanTransfersManager()
        let responseUsualTransfer = try transferManager.getUsualTransfers()
        guard
            responseUsualTransfer.isSuccess(),
            let dataUsualTransfer = try responseUsualTransfer.getResponseData(),
            dataUsualTransfer.count > 0
        else {
            guard loadingFromNetwork else { return [] }
            _ = try transferManager.loadUsualTransfers()
            return try getUsualTransfers(loadingFromNetworkIfNeeded: false)
        }
        return dataUsualTransfer
    }
}

struct SetupOnePayTransferCardUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    let favouriteList: [Favourite]
    let maxAmount: Amount?
    let payer: String
    let baseUrl: String?
    let enabledFavouritesCarrusel: Bool
    let favoriteContacts: [String]?
    let summaryUserName: String
}

extension SetupOnePayTransferCardUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}
