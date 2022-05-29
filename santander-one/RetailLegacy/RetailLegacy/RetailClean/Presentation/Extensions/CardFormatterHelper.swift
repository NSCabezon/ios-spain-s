protocol CardFormatterHelpers {}

extension CardFormatterHelpers {
    
    func getStyledSubNameFor(_ card: Card, stringLoader: StringLoader) -> LocalizedStylableText {
        let key: String
        if card.isPrepaidCard {
            key = "pg_label_ecashCard"
        } else if card.isCreditCard {
            key = "pg_label_creditCard"
        } else {
            key = "pg_label_debitCard"
        }
        
        return stringLoader.getString(key, [StringPlaceholder(.value, card.getPANShort())])
    }
    
}
