//
//  GetPGFrequentOperativeOption.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 09/04/2021.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class GetPGFrequentOperativeOption {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension GetPGFrequentOperativeOption: GetPGFrequentOperativeOptionProtocol {
    func get(globalPositionType: GlobalPositionOptionEntity?) -> [PGFrequentOperativeOptionProtocol] {
        guard globalPositionType != GlobalPositionOptionEntity.simple else {
            return self.getSimplePGFrequentOperatives()
        }
        return self.getPGFrequentOperatives()
    }
    
    func getDefault() -> [PGFrequentOperativeOptionProtocol] {
        return self.getDefaultPGFrequentOperatives()
    }
}

private extension GetPGFrequentOperativeOption {
    func getPGFrequentOperatives() -> [PGFrequentOperativeOptionProtocol] {
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        var frequentOperatives: [PGFrequentOperativeOptionProtocol]
        let listShortcutsPG1 = appConfigRepository.getAppConfigListNode("shortcutsPG1") ?? []
        let listShortcutsPG2 = appConfigRepository.getAppConfigListNode("shortcutsPG2") ?? []
        let listShortcutsPG3 = appConfigRepository.getAppConfigListNode("shortcutsPG3") ?? []
        let bsanManagersProvider: BSANManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let bsanPullOffersManager = bsanManagersProvider.getBsanPullOffersManager()
        let userCampaigns = try? (bsanPullOffersManager.getCampaigns().getResponseData()) ?? []
        let shortcuts = [listShortcutsPG1, listShortcutsPG2, listShortcutsPG3].enumerated().first {
            $0.element.first { userCampaigns?.contains($0) == true } != nil
        }
        switch shortcuts?.offset {
        case 0?:
            frequentOperatives = self.getConfigurationOnePGFrequentOperatives()
        case 1?:
            frequentOperatives = self.getConfigurationTwoPGFrequentOperatives()
        case 2?:
            frequentOperatives = self.getConfigurationThreePGFrequentOperatives()
        default:
            frequentOperatives = self.getDefaultPGFrequentOperatives()
        }
        return frequentOperatives
    }
    
    func getDefaultPGFrequentOperatives() -> [PGFrequentOperativeOptionProtocol] {
        return [
            PGFrequentOperativeOption.operate,
            PGFrequentOperativeOption.contract,
            PGFrequentOperativeOption.billTax,
            BizumPGFrequentOperativeOption(dependenciesResolver: dependenciesResolver),
            PGFrequentOperativeOption.sendMoney,
            PGFrequentOperativeOption.marketplace,
            PGFrequentOperativeOption.analysisArea,
            PGFrequentOperativeOption.financialAgenda,
            PGFrequentOperativeOption.suscription,
            PGFrequentOperativeOption.customerCare,
            PGFrequentOperativeOption.investmentPosition,
            PGFrequentOperativeOption.impruve,
            PGFrequentOperativeOption.stockholders,
            PGFrequentOperativeOption.atm,
            PGFrequentOperativeOption.personalArea,
            PGFrequentOperativeOption.myManage,
            PGFrequentOperativeOption.addBanks,
            PGFrequentOperativeOption.financialAnalysis,
            PGFrequentOperativeOption.financialTips,
            PGFrequentOperativeOption.financing,
            PGFrequentOperativeOption.onePlan,
            PGFrequentOperativeOption.shortcut,
            PGFrequentOperativeOption.correosCash,
            PGFrequentOperativeOption.officeAppointment,
            PGFrequentOperativeOption.investmentsProposals,
            PGFrequentOperativeOption.automaticOperations,
            PGFrequentOperativeOption.carbonFootprint
        ]
    }
    
    func getSimplePGFrequentOperatives() -> [PGFrequentOperativeOptionProtocol] {
        return [
            PGFrequentOperativeOption.operate,
            PGFrequentOperativeOption.contract,
            PGFrequentOperativeOption.billTax,
            PGFrequentOperativeOption.sendMoney
        ]
    }
    
    func getConfigurationOnePGFrequentOperatives() -> [PGFrequentOperativeOptionProtocol] {
        return [
            PGFrequentOperativeOption.operate,
            PGFrequentOperativeOption.sendMoney,
            PGFrequentOperativeOption.analysisArea,
            BizumPGFrequentOperativeOption(dependenciesResolver: dependenciesResolver),
            PGFrequentOperativeOption.contract,
            PGFrequentOperativeOption.billTax,
            PGFrequentOperativeOption.marketplace,
            PGFrequentOperativeOption.financialAgenda,
            PGFrequentOperativeOption.suscription,
            PGFrequentOperativeOption.customerCare,
            PGFrequentOperativeOption.investmentPosition,
            PGFrequentOperativeOption.impruve,
            PGFrequentOperativeOption.stockholders,
            PGFrequentOperativeOption.atm,
            PGFrequentOperativeOption.personalArea,
            PGFrequentOperativeOption.myManage,
            PGFrequentOperativeOption.addBanks,
            PGFrequentOperativeOption.financialAnalysis,
            PGFrequentOperativeOption.financialTips,
            PGFrequentOperativeOption.financing,
            PGFrequentOperativeOption.onePlan,
            PGFrequentOperativeOption.shortcut,
            PGFrequentOperativeOption.correosCash,
            PGFrequentOperativeOption.officeAppointment,
            PGFrequentOperativeOption.investmentsProposals,
            PGFrequentOperativeOption.automaticOperations,
            PGFrequentOperativeOption.carbonFootprint
        ]
    }
    
    func getConfigurationTwoPGFrequentOperatives() -> [PGFrequentOperativeOptionProtocol] {
        return [
            PGFrequentOperativeOption.atm,
            BizumPGFrequentOperativeOption(dependenciesResolver: dependenciesResolver),
            PGFrequentOperativeOption.financialAgenda,
            PGFrequentOperativeOption.consultPin,
            PGFrequentOperativeOption.billTax,
            PGFrequentOperativeOption.operate,
            PGFrequentOperativeOption.contract,
            PGFrequentOperativeOption.sendMoney,
            PGFrequentOperativeOption.marketplace,
            PGFrequentOperativeOption.analysisArea,
            PGFrequentOperativeOption.suscription,
            PGFrequentOperativeOption.customerCare,
            PGFrequentOperativeOption.investmentPosition,
            PGFrequentOperativeOption.impruve,
            PGFrequentOperativeOption.stockholders,
            PGFrequentOperativeOption.personalArea,
            PGFrequentOperativeOption.myManage,
            PGFrequentOperativeOption.addBanks,
            PGFrequentOperativeOption.financialAnalysis,
            PGFrequentOperativeOption.financialTips,
            PGFrequentOperativeOption.financing,
            PGFrequentOperativeOption.onePlan,
            PGFrequentOperativeOption.shortcut,
            PGFrequentOperativeOption.correosCash,
            PGFrequentOperativeOption.officeAppointment,
            PGFrequentOperativeOption.investmentsProposals,
            PGFrequentOperativeOption.automaticOperations,
            PGFrequentOperativeOption.carbonFootprint
        ]
    }
    
    func getConfigurationThreePGFrequentOperatives() -> [PGFrequentOperativeOptionProtocol] {
        return [
            PGFrequentOperativeOption.marketplace,
            PGFrequentOperativeOption.analysisArea,
            BizumPGFrequentOperativeOption(dependenciesResolver: dependenciesResolver),
            PGFrequentOperativeOption.sendMoney,
            PGFrequentOperativeOption.operate,
            PGFrequentOperativeOption.contract,
            PGFrequentOperativeOption.billTax,
            PGFrequentOperativeOption.financialAgenda,
            PGFrequentOperativeOption.suscription,
            PGFrequentOperativeOption.customerCare,
            PGFrequentOperativeOption.investmentPosition,
            PGFrequentOperativeOption.impruve,
            PGFrequentOperativeOption.stockholders,
            PGFrequentOperativeOption.atm,
            PGFrequentOperativeOption.personalArea,
            PGFrequentOperativeOption.myManage,
            PGFrequentOperativeOption.addBanks,
            PGFrequentOperativeOption.financialAnalysis,
            PGFrequentOperativeOption.financialTips,
            PGFrequentOperativeOption.financing,
            PGFrequentOperativeOption.onePlan,
            PGFrequentOperativeOption.shortcut,
            PGFrequentOperativeOption.correosCash,
            PGFrequentOperativeOption.officeAppointment,
            PGFrequentOperativeOption.investmentsProposals,
            PGFrequentOperativeOption.automaticOperations,
            PGFrequentOperativeOption.carbonFootprint
        ]
    }
}
