import CoreFoundationLib

struct ShareIbanFormatter: ShareIbanFormatterProtocol {
    func ibanPapel(_ iban: IBANEntity?) -> String {
        guard let iban = iban?.ibanPapel else { return "****" }
        return iban
    }
    
    func shareAccountNumber(_ account: AccountEntity) -> String {
        guard let iban = account.getIban()?.ibanPapel else { return "****" }
        return iban
    }
}
