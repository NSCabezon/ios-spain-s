import Foundation
import PersonalArea
import CoreFoundationLib
import SANLegacyLibrary
import Bizum
import CoreDomain

final class SpainDigitalProfileItemsProvider {
    private let dependenciesResolver: DependenciesResolver
    private lazy var appConfigRepository: AppConfigRepositoryProtocol = {
        return dependenciesResolver.resolve()
    }()
    private lazy var provider: BSANManagersProvider = {
        return dependenciesResolver.resolve()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension SpainDigitalProfileItemsProvider: DigitalProfileItemsProviderProtocol {
    func getItems() -> (configuredItems: [DigitalProfileElemProtocol], notConfiguredItems: [DigitalProfileElemProtocol]) {
        let item = SpainDigitalProfileItem()
        var configuredItems: [DigitalProfileElemProtocol] = []
        var notConfiguredItems: [DigitalProfileElemProtocol] = []
        let isConfigured = self.isCheckPaymentSuccess()
        if isConfigured {
            configuredItems.append(item)
        } else {
            notConfiguredItems.append(item)
        }
        return (configuredItems, notConfiguredItems)
    }
    
    func didSelect(item: DigitalProfileElemProtocol) {
        switch item.identifier {
        case "bizum":
            let coordinator = dependenciesResolver.resolve(for: BizumStartCapable.self)
            coordinator.launchBizum()
        default: break
        }
    }
}

extension SpainDigitalProfileItemsProvider {
    func isCheckPaymentSuccess() -> Bool {
        let defaultXPAN = appConfigRepository.getString(BizumHomeConstants.bizumDefaultXPAN) ?? ""
        if let checkPayment = try? self.provider.getBSANBizumManager().checkPayment(defaultXPAN: defaultXPAN) {
            return checkPayment.isSuccess()
        } else {
            return false
        }
    }
}
