public enum PrepaidCardHeaderElements {
    case availableBalance
    case spentThisMonth
}

public enum DebitCardHeaderElements {
    case spentThisMonth
    case tradeLimit
    case atmLimit
}

public enum CreditCardHeaderElements {
    case limitCredit
    case availableCredit
    case withdrawnCredit
}

public enum CardDetailShareType {
    case pan
    case accountNumber
}
