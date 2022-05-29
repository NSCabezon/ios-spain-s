enum ChargeDischargeType {
    case charge(amount: String)
    case discharge(amount: String)
    
    func localizedTitle(with stringLoader: StringLoader) -> LocalizedStylableText {
        switch self {
        case .charge:
            return stringLoader.getString("chargeDischarge_label_charge")
        case .discharge:
            return stringLoader.getString("chargeDischarge_label_discharge")
        }
    }
    
    func radioOrderTypeItemType(with stringLoader: StringLoader) -> OrderTypeItemType {
        switch self {
        case .charge(let value):
            return .amount(placeholder: .empty, value: value)
        case .discharge(let value):
            return .amount(placeholder: .empty, value: value)
        }
    }
    
    func getAmount() -> String {
        switch self {
        case .charge(let value):
            return value
        case .discharge(let value):
            return value
        }
    }
}
