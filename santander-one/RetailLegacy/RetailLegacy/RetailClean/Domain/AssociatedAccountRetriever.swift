import Foundation
import SANLegacyLibrary

protocol AssociatedAccountRetriever: class {
    func getLinkedAccount(provider: BSANManagersProvider, ibanDTO: IBANDTO) throws -> BSANResponse<AccountDTO>
}

extension AssociatedAccountRetriever {
    func getLinkedAccount(provider: BSANManagersProvider, ibanDTO: IBANDTO) throws -> BSANResponse<AccountDTO> {
        let responseAccounts = try provider.getBsanAccountsManager().getAllAccounts()
        if responseAccounts .isSuccess(), let listAccounts = try responseAccounts.getResponseData(), !listAccounts.isEmpty {
            let account = listAccounts.filter { $0.iban == ibanDTO }.first
            return BSANOkResponse(account)
        }
        return BSANOkResponse(Meta.createOk())
    }
}
