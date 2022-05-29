import Foundation
import Transfer
import CoreFoundationLib
import Bizum

final class SpainTransferHomeActionModifier {
    
    let dependenciesResolver: DependenciesResolver
    private let bizum: TransferActionType = .custome(
        identifier: "bizum",
        title: "transferOption_button_bizum",
        description: "transferOption_text_bizum",
        icon: "icnBizum"
    )
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func didSelectTransferHomeAction(type: TransferActionType, account: AccountEntity?) {
        switch type {
        case .custome:
            self.trackEvent(.bizum, parameters: [:])
            let coordinator: BizumStartCapable = dependenciesResolver.resolve(for: BizumStartCapable.self)
            coordinator.launchBizum()
        default:
            break
        }
    }
}

extension SpainTransferHomeActionModifier: TransferHomeModifierActionsDataSource {
    func getHomeTransferActions(_ transferBetweenAccountsAvailable: Bool) -> [TransferActionType] {
        if transferBetweenAccountsAvailable {
            return [.transfer, .transferBetweenAccounts, bizum, .onePayFX(nil), .atm, .correosCash(nil), .scheduleTransfers, .donations(nil)]
        }
        return [.transfer, bizum, .onePayFX(nil), .atm, .correosCash(nil), .scheduleTransfers, .donations(nil)]
    }
    
    func getNewShipmentTransferActions(_ transferBetweenAccountsAvailable: Bool) -> [TransferActionType] {
        if transferBetweenAccountsAvailable {
            return [.transfer, .transferBetweenAccounts, bizum, .onePayFX(nil), .atm]
        }
        return [.transfer, bizum, .onePayFX(nil), .atm]
    }
}

extension SpainTransferHomeActionModifier: TransferHomeModifierActionsDelegate {
    func didSelectTransferAction(type: TransferActionType, account: AccountEntity?) {
        self.didSelectTransferHomeAction(type: type, account: account)
    }
    
    func canHandleAction(_ type: TransferActionType) -> Bool {
        switch type {
        case .custome(identifier: let identifier, _, _, _):
            switch identifier {
            case "bizum": return true
            default: return false
            }
        default: return false
        }
    }
}

extension SpainTransferHomeActionModifier: AutomaticScreenEmmaActionTrackable {
    var trackerPage: TransfersHomeSendMoneyPage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependenciesResolver.resolve()
        let emmaToken = emmaTrackEventList.transfersEventID
        return TransfersHomeSendMoneyPage(emmaToken: emmaToken)
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
