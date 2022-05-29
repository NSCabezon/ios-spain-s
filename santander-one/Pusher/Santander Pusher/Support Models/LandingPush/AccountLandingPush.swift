struct AccountLandingPush: Encodable {
    var accountName: String
    var ccc: String
    var date: String?
    var currency: String?
    var value: String?
}

struct AccountAlertInfo: Encodable {
    let name: AccountLandingType
    let category: LandingPushCategory = .account
    let user: String
}

enum AccountLandingType: String, Encodable {
    case overdraft = "0024"
    case transaction = "0030"
    case bill = "0035"
    case lowerBalance = "0026"
    case emittedTransfer = "0028"
}
