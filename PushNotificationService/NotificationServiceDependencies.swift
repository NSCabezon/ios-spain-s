//
// RetailClean
// Created on 16/12/2020
//

import Foundation
import CoreFoundationLib
import SanNotificationService

struct NotificationServiceDependencies: NotificationServiceDependenciesProtocol {
    let versionInfo: VersionInfoDTO
    let udDataSource: UDDataSource
    let udDataRepository: DataRepository
    let daoSharedPersistedUser: DAOSharedPersistedUserProtocol
    let daoUserPref: DAOSharedUserPrefEntityProtocol
    let otpUseCase: SANSaveOtpNotificationUseCase
    let ecommerceUseCase: SaveEcommerceNotificationUseCase
    
    init() {
        versionInfo = VersionInfoDTO(
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
            versionName: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        )
        let sharedKeyChainService = SharedKeyChainService(accessGroupName: Compilation.Keychain.sharedTokenAccessGroup)
        self.udDataSource = UDDataSource(
            serializer: JSONSerializer(),
            appInfo: versionInfo,
            keychainService: sharedKeyChainService,
            domain: .suite(name: Compilation.appGroupsIdentifier)
        )
        self.udDataRepository = DataRepositoryImpl(
            dataSourceProvider: DataSourceProviderImpl(
                defaultDataSource: udDataSource,
                dataSources: [udDataSource]
            ),
            appInfo: versionInfo
        )
        self.daoSharedPersistedUser = DAOSharedPersistedUser(dataRepository: udDataRepository)
        self.daoUserPref = DAOSharedUserPrefEntity(dataRepository: udDataRepository)
        self.otpUseCase = SANSaveOtpNotificationUseCase(
            daoSharedPersistedUserProtocol: daoSharedPersistedUser,
            daoUserPref: daoUserPref
        )
        self.ecommerceUseCase = SaveEcommerceNotificationUseCase(
            daoSharedPersistedUserProtocol: daoSharedPersistedUser,
            daoUserPref: daoUserPref
        )
    }
}
