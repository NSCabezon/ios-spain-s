struct CardDetailProduct {
    enum CardDetailProductType {
        case icon(masked: Bool)
        case basic
        case editable
    }
    let title: String
    let value: String
    let type: CardDetailProductType
    let dataType: CardDetailDataType
}
