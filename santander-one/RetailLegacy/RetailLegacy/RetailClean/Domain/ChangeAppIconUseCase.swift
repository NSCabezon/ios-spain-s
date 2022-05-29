//
//  ChangeAppIconUseCase.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 25/09/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreDomain
import CoreFoundationLib
import SANLegacyLibrary


final class ChangeAppIconUseCase: UseCase<Void, ChangeAppIconUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    private var accountDescriptorRepository: AccountDescriptorRepository
    private let appConfigRepository: AppConfigRepository
    
    init(dependenciesResolver: DependenciesResolver, bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<ChangeAppIconUseCaseOkOutput, StringErrorOutput> {
        let accountDescriptorRepositoryProtocol = self.dependenciesResolver.resolve(for: AccountDescriptorRepositoryProtocol.self)
        let appIconsInfo = accountDescriptorRepositoryProtocol.getAccountDescriptor()?.appIcons.map {
            AppIconEntity(startDate: $0.startDate ?? "", endDate: $0.endDate ?? "", iconName: $0.iconName ?? "")
            } ?? []
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper, let scaDate = getScaDate(bsanManagersProvider) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let userPrefDTOEntity = appRepository.getUserPreferences(userId: globalPositionWrapper.userId)
        let userPrefEntity = UserPrefEntity.from(dto: userPrefDTOEntity)
        let validCampaign = getValidCampaign(scaDate, alternativeAppIcons: appIconsInfo)
        let savedCampaign: AppIconEntity? = userPrefEntity.getTransitiveAppIcon()
        guard let iconToChange = validCampaign else {
            if savedCampaign != nil {
                userPrefDTOEntity.pgUserPrefDTO.transitiveAppIcon = nil
                appRepository.setUserPreferences(userPref: userPrefEntity.userPrefDTOEntity)
                return UseCaseResponse.ok(ChangeAppIconUseCaseOkOutput(appIconEntity: nil, userPrefEntity: nil, status: .finishedCampaign))
            }
            return UseCaseResponse.ok(ChangeAppIconUseCaseOkOutput(appIconEntity: nil, userPrefEntity: nil, status: .notValid))
        }
        let statusIsExistsCampaign: ChangeAppIconStatusType = (savedCampaign != nil && savedCampaign == iconToChange) ? .notValid : .valid
        return UseCaseResponse.ok(ChangeAppIconUseCaseOkOutput(appIconEntity: iconToChange, userPrefEntity: userPrefEntity, status: statusIsExistsCampaign))
    }
}

private extension ChangeAppIconUseCase {
    func getValidCampaign(_ scaDate: Date, alternativeAppIcons: [AppIconEntity]) -> AppIconEntity? {
        let timeManager = dependenciesResolver.resolve(for: TimeManager.self)
        let appIcon = alternativeAppIcons.first { (appIconInfo) -> Bool in
            guard let startDate = timeManager.fromString(input: appIconInfo.startDate, inputFormat: .ddMMyyyy_HHmm),
                let endDate = timeManager.fromString(input: appIconInfo.endDate, inputFormat: .ddMMyyyy_HHmm),
                startDate < endDate else {
                    return false
            }
            return (startDate ... endDate).contains(scaDate)
        }
        return appIcon
    }
    
    func getScaDate(_ provider: BSANManagersProvider) -> Date? {
        let scaManager: BSANScaManager = provider.getBsanScaManager()
        let response: BSANResponse<CheckScaDTO>? = try? scaManager.checkSca()
        guard response?.isSuccess() ?? false,
            let checkScaDTO: CheckScaDTO = try? response?.getResponseData() else {
            return nil
        }
        return checkScaDTO.systemDate
    }
}

struct ChangeAppIconUseCaseOkOutput {
    let appIconEntity: AppIconEntity?
    let userPrefEntity: UserPrefEntity?
    let status: ChangeAppIconStatusType
}

enum ChangeAppIconStatusType {
    case valid
    case notValid
    case finishedCampaign
}
