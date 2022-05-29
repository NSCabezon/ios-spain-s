import SANLegacyLibrary
import CoreFoundationLib

final class GlobalPositionWrapperFactory {
    static func getWrapper(bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository) throws -> GlobalPositionWrapper? {
        let isPB = try bsanManagersProvider.getBsanSessionManager().isPB().getResponseData() ?? false
        let enableCounterValue = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigCounterValueEnabled)
        let enableInsuranceDetail = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigInsuranceDetailEnabled)
        let globalPositionConfig = GlobalPositionConfig(enableCounterValue: enableCounterValue, enableInsuranceDetail: enableInsuranceDetail)
        let notManagedRVStockAccounts = try bsanManagersProvider.getBsanPortfoliosPBManager().getRVNotManagedStockAccountList().getResponseData()
        let managedRVStockAccounts = try bsanManagersProvider.getBsanPortfoliosPBManager().getRVManagedStockAccountList().getResponseData()
        let notManagedPortfolios = try bsanManagersProvider.getBsanPortfoliosPBManager().getPortfoliosNotManaged().getResponseData()
        let managedPortfolios = try bsanManagersProvider.getBsanPortfoliosPBManager().getPortfoliosManaged().getResponseData()
        guard let gPositionDTO = try bsanManagersProvider.getBsanPGManager().getGlobalPosition().getResponseData() else { return nil }
        let userSegmentDTO = try bsanManagersProvider.getBsanUserSegmentManager().getUserSegment().getResponseData()
        let cardsData = try bsanManagersProvider.getBsanCardsManager().getCardsDataMap().getResponseData()
        let prepaidCards = try bsanManagersProvider.getBsanCardsManager().getPrepaidsCardsDataMap().getResponseData()
        let cardBalances = try bsanManagersProvider.getBsanCardsManager().getCardsBalancesMap().getResponseData()
        let temporallyInactiveCards = try bsanManagersProvider.getBsanCardsManager().getTemporallyInactiveCardsMap().getResponseData()
        let inactiveCards = try bsanManagersProvider.getBsanCardsManager().getInactiveCardsMap().getResponseData()
        let isMixedUser = try appRepository.isMixedUser().getResponseData() ?? false
        let isInsuranceBalanceEnabled = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigInsuranceBalanceEnabled) ?? false
        let arrayDTO = accountDescriptorRepository.get()?.accountsArray
        return GlobalPositionWrapper.createFromDTO(
            isPb: isPB,
            isMixedUser: isMixedUser,
            globalPositionConfig: globalPositionConfig,
            dto: gPositionDTO,
            cardsData: cardsData,
            prepaidCards: prepaidCards,
            cardBalances: cardBalances,
            temporallyOffCards: temporallyInactiveCards,
            inactiveCards: inactiveCards,
            notManagedRVStockAccounts: notManagedRVStockAccounts,
            managedRVStockAccounts: managedRVStockAccounts,
            notManagedPortfolios: notManagedPortfolios,
            managedPortfolios: managedPortfolios,
            userSegmentDTO: userSegmentDTO,
            accountDescriptors: arrayDTO,
            isInsuranceAmountEnabled: isInsuranceBalanceEnabled)
    }
    
    static func getEntity(bsanManagersProvider: BSANManagersProvider) -> GlobalPositionEntity {
        let gPositionDTO = try? bsanManagersProvider.getBsanPGManager().getGlobalPosition().getResponseData()
        let isPB = try? bsanManagersProvider.getBsanSessionManager().isPB().getResponseData()
        let notManagedPortfolios = try? bsanManagersProvider.getBsanPortfoliosPBManager().getPortfoliosNotManaged().getResponseData()
        let managedPortfolios = try? bsanManagersProvider.getBsanPortfoliosPBManager().getPortfoliosManaged().getResponseData()
        let notManagedRVStockAccounts = try? bsanManagersProvider.getBsanPortfoliosPBManager().getRVNotManagedStockAccountList().getResponseData()
        let managedRVStockAccounts = try? bsanManagersProvider.getBsanPortfoliosPBManager().getRVManagedStockAccountList().getResponseData()
        let cardsData = try? bsanManagersProvider.getBsanCardsManager().getCardsDataMap().getResponseData()
        let prepaidCards = try? bsanManagersProvider.getBsanCardsManager().getPrepaidsCardsDataMap().getResponseData()
        let cardBalances = try? bsanManagersProvider.getBsanCardsManager().getCardsBalancesMap().getResponseData()
        let temporallyInactiveCards = try? bsanManagersProvider.getBsanCardsManager().getTemporallyInactiveCardsMap().getResponseData()
        let inactiveCards = try? bsanManagersProvider.getBsanCardsManager().getInactiveCardsMap().getResponseData()
        return GlobalPositionEntity(
            isPb: isPB,
            dto: gPositionDTO,
            cardsData: cardsData,
            prepaidCards: prepaidCards,
            cardBalances: cardBalances,
            temporallyOffCards: temporallyInactiveCards,
            inactiveCards: inactiveCards,
            notManagedPortfolios: notManagedPortfolios,
            managedPortfolios: managedPortfolios,
            notManagedRVStockAccounts: notManagedRVStockAccounts,
            managedRVStockAccounts: managedRVStockAccounts
        )
    }
}
