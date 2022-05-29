//

import Foundation

struct ConfirmChangeMassiveDirectDebitsAccountRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let accountDTO: AccountDTO?
    let language: String
    let dialect: String
    let signature: SignatureWithTokenDTO
    
    @available(iOS, deprecated: 5.0.10, message: "Pending to delete AccountDTO optional in next version")
    init(token: String, userDataDTO: UserDataDTO, language: String, dialect: String, signature: SignatureWithTokenDTO) {
        self.token = token
        self.userDataDTO = userDataDTO
        self.accountDTO = nil
        self.language = language
        self.dialect = dialect
        self.signature = signature
    }
    
    init(token: String, userDataDTO: UserDataDTO, accountDTO: AccountDTO, language: String, dialect: String, signature: SignatureWithTokenDTO) {
        self.token = token
        self.userDataDTO = userDataDTO
        self.accountDTO = accountDTO
        self.language = language
        self.dialect = dialect
        self.signature = signature
    }
}
