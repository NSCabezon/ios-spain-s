import CoreFoundationLib

final class AccountsHomeModuleCoordinatorMock: AccountsHomeCoordinatorDelegate{
    func showLoading() {}
    func didGenerateTransactionsPDF(for account: AccountEntity, holder: String?, fromDate: Date?, toDate: Date?, transactions: [AccountTransactionEntity], showDisclaimer: Bool) {}
    func didSelectAction(action: AccountActionType, entity: AccountEntity?) {}
    func goToWebView(configuration: WebViewConfiguration) {}
    func didSelectDownloadTransactions(for account: AccountEntity, withFilters: TransactionFiltersEntity?, withScaSate scaState: ScaState?) {}
    func didSelectOffer(offer: OfferEntity) {}
    func didSelectAction(_ action: AccountActionType, _ entity: AccountEntity) {}
    func handleScaState(_ state: ScaState) {}
    func didSelectDetail(for account: AccountEntity) {}
    func didSelectSearch() {}
    func didSelectShowFilters() {}
    func didSelectDownloadTransactions(for account: AccountEntity, withScaSate scaState: ScaState?) {}
    func didSelectDismiss() {}
    func didSelectMenu() {}
    func didSelectMoreOptions() {}
    func didSelectTransaction(_ transaction: AccountTransactionEntity, in transactions: [AccountTransactionEntity], for account: AccountEntity) {}
    func didSelectShare(for account: AccountEntity) {}
    func showDialog(acceptTitle: LocalizedStylableText?, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText?, showsCloseButton: Bool, source: UIViewController, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {}
    func accountsHomeDidAppear() {}
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate, scaTransactionParams: SCATransactionParams) {}
    func getCurrentLanguage() -> LanguageType { return .english }
    func changeLanguage(language: LanguageType) { }
    func getUserPreferencesMigration(userId: String) -> UserPrefDTOEntity { UserPrefDTOEntity(userId: "") }
    func getUserPreferences(userId: String) -> UserPrefDTOEntity { UserPrefDTOEntity(userId: "") }
    func setUserPreferences(userPref: UserPrefDTOEntity) { }
    func isTipsEmpty() -> Bool { return false }
}
