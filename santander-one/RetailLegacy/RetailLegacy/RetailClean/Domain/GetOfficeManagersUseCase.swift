//
// Created by SYS_CIBER_ADMIN on 13/4/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetOfficeManagersUseCase: UseCase<Void, GetOfficeManagersUseCaseOkOutput, GetOfficeManagersUseCaseErrorOutput> {

    private let bsanManagersProvider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository

    init(bsanManagersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.bsanManagersProvider = bsanManagersProvider
        self.appConfigRepository = appConfigRepository
        super.init()
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetOfficeManagersUseCaseOkOutput, GetOfficeManagersUseCaseErrorOutput> {
        let response = try bsanManagersProvider.getBsanManagersManager().getManagers()
        if !response.isSuccess() {
            return UseCaseResponse.error(GetOfficeManagersUseCaseErrorOutput(try response.getErrorMessage()))
        }
        
        let portfolioTypeList = appConfigRepository.getAppConfigListNode(DomainConstant.appConfigManagerSantanderPersonal)
       
        if let managerListDTO = try checkRepositoryResponse(response)?.managerList {
            let filteredList = managerListDTO.filter {
                if let portfolioTypeList = portfolioTypeList {
                    return !portfolioTypeList.contains($0.portfolioType ?? "")
                }
                return true
            }
            return UseCaseResponse.ok(GetOfficeManagersUseCaseOkOutput(managerList: ManagerList(managerListDTO: filteredList)))
        }
        return UseCaseResponse.ok(GetOfficeManagersUseCaseOkOutput(managerList: ManagerList(managerListDTO: [])))
    }
}

class GetOfficeManagersUseCaseOkOutput {

    let managerList: ManagerList

    init(managerList: ManagerList) {
        self.managerList = managerList
    }
}

class GetOfficeManagersUseCaseErrorOutput: StringErrorOutput {
}
