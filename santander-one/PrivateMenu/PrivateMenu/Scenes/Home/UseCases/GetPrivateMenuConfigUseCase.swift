import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetPrivateMenuConfigUseCase {
    func fetchPrivateConfigMenuData() -> AnyPublisher<PrivateMenuConfigRepresentable, Never>
}

struct DefaultGetPrivateMenuConfigUseCase {
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        appConfigRepository = dependencies.resolve()
    }
}

extension DefaultGetPrivateMenuConfigUseCase: GetPrivateMenuConfigUseCase {
    func fetchPrivateConfigMenuData() -> AnyPublisher<PrivateMenuConfigRepresentable, Never> {
        return getPrivateConfigMenu()
    }
}

private extension DefaultGetPrivateMenuConfigUseCase {
    struct PrivateMenu: PrivateMenuConfigRepresentable {
        let isMarketplaceEnabled: Bool
        let isEnabledBillsAndTaxesInMenu: Bool
        let isEnabledExploreProductsInMenu: Bool
        let isVirtualAssistantEnabled: Bool
        let sanflixEnabled: Bool
        let enablePublicProducts: Bool
        let enableComingFeatures: Bool
        let enableFinancingZone: Bool
        let enableStockholders: Bool
        let enableManagerMenu: Bool
    }
    
    func getPrivateConfigMenu() -> AnyPublisher<PrivateMenuConfigRepresentable, Never> {
        let configValues: AnyPublisher<[Bool?], Never> = appConfigRepository
            .values(for: ["enableMarketplace",
                          "enabledBillsAndTaxesInMenu",
                          "enabledExploreProductsInMenu",
                          "enableVirtualAssistant",
                          "enableApplyBySanflix",
                          "enablePublicProducts",
                          "enableComingFeatures",
                          "enableFinancingZone",
                          "enableStockholders",
                          "enableManagerMenu"
                         ])
        let publisher = configValues
            .map() { value -> PrivateMenuConfigRepresentable in
                return PrivateMenu(
                    isMarketplaceEnabled: value[0] ?? false, isEnabledBillsAndTaxesInMenu: value[1] ?? false, isEnabledExploreProductsInMenu: value[2] ?? false, isVirtualAssistantEnabled: value[3] ?? false,
                    sanflixEnabled: value[4] ?? false,
                    enablePublicProducts: value[5] ?? false,
                    enableComingFeatures: value[6] ?? false,
                    enableFinancingZone: value[7] ?? false,
                    enableStockholders: value[8] ?? false,
                    enableManagerMenu: value[9] ?? false)
            }
        return publisher.eraseToAnyPublisher()
    }
}
