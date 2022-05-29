import CoreFoundationLib

public final class AppInfoRepositoryMock: AppInfoRepositoryProtocol {
    public init() {}
    public func load(baseUrl: String, publicLanguage: PublicLanguage) {}
    public func getAppInfo() -> AppVersionsInfoDTO? {
        return nil
    }
}
