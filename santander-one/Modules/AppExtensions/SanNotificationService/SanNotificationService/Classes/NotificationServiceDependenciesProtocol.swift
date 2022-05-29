import CoreFoundationLib

public protocol NotificationServiceDependenciesProtocol {
    var versionInfo: VersionInfoDTO { get }
    var udDataSource: UDDataSource { get }
    var udDataRepository: DataRepository { get }
    var daoSharedPersistedUser: DAOSharedPersistedUserProtocol { get }
    var daoUserPref: DAOSharedUserPrefEntityProtocol { get }
    var otpUseCase: SANSaveOtpNotificationUseCase { get }
    var ecommerceUseCase: SaveEcommerceNotificationUseCase { get }
}
