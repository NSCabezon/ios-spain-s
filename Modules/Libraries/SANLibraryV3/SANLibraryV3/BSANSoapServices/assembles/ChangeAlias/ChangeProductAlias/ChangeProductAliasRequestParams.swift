//

import Foundation

struct ChangeProductAliasRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let languageISO: String
    let dialectISO: String
    let linkedCompany: String
    let accountDTO: AccountDTO
    let newAlias: String
}
