import Foundation

public enum AccessibilitySavingDetails: String {
    case detailView
    case titleDetail
    case subtitleDetail
    case icnCheckToast
    case copyTitle = "generic_label_copy"
}

public enum AccessibilitySavingsShortcuts: String {
    case sendMoney = "_sendMoney"
    case sendMoneyFromSrc = "_sendMoneyFromSrc"
    case savingDetails = "_savingDetails"
    case termDetails = "_termDetails"
    case savingGoals = "_savingGoals"
    case changeAlias = "_changeAlias"
    case openTermDeposit = "_openTermDeposit"
    case closeTermDeposit = "_closeTermDeposit"
    case alerts24 = "_alerts24"
    case statementHistory = "_statementHistory"
    case customerService = "_customerService"
    case ourOffer = "_ourOffer"
    case regularPayments = "_regularPayments"
    case reportCard = "_reportCard"
    case apply = "_apply"
    case titleLabel = "titleLabel_"
    case navigationBarTitle = "title_yourShortcuts"
}

public enum AccessibilitySavingsShortcutSections: String {
    case settings = "_settings"
    case queries = "_queries"
    case offer = "_offer"
}
