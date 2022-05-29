//*
/**
RetailClean
Created on 16/12/2020
*/

import CoreFoundationLib
import Ecommerce
import Foundation
import SanNotificationService

struct NotificationServiceDependencies: NotificationServiceDependenciesProtocol {
    var versionInfo: VersionInfoDTO {
        return VersionInfoDTO(
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
            versionName: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
    }
    var udDataSource: UDDataSource {
        let sharedKeyChainService = SharedKeyChainService(accessGroupName: Compilation.Keychain.sharedTokenAccessGroup)
        return UDDataSource(serializer: JSONSerializer(), appInfo: versionInfo, keychainService: sharedKeyChainService, domain: .suite(name: Compilation.appGroupsIdentifier))
    }
    var udDataRepository: DataRepository {
        return DataRepositoryImpl(dataSourceProvider: DataSourceProviderImpl(defaultDataSource: udDataSource, dataSources: [udDataSource]), appInfo: versionInfo)
    }
    var daoSharedPersistedUser: DAOSharedPersistedUserProtocol {
        return DAOSharedPersistedUser(dataRepository: udDataRepository)
    }
    var daoUserPref: DAOSharedUserPrefEntityProtocol {
        return DAOSharedUserPrefEntity(dataRepository: udDataRepository)
    }
    var otpUseCase: SaveOtpNotificationUseCase {
        return SaveOtpNotificationUseCase(daoSharedPersistedUserProtocol: daoSharedPersistedUser, daoUserPref: daoUserPref)
    }
    var ecommerceUseCase: SaveEcommerceNotificationUseCase {
        return SaveEcommerceNotificationUseCase(daoSharedPersistedUserProtocol: daoSharedPersistedUser, daoUserPref: daoUserPref)
    }
}
