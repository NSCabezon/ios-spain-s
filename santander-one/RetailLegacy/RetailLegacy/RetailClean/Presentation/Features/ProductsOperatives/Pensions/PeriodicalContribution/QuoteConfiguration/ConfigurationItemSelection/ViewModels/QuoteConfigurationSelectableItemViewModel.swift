enum QuoteConfigurationSelectableType {
    case empty
    case percentage(placeholder: LocalizedStylableText, value: String?)
}

class QuoteConfigurationSelectableItemViewModel: RadioTableModelView {
    
    let type: QuoteConfigurationSelectableType
    let view: QuoteConfigurationSelectableItem
    
    init(title: LocalizedStylableText, type: QuoteConfigurationSelectableType, tag: Int, radio: RadioTable, isInitialIndex: Bool, privateComponent: PresentationComponent) {
        self.type = type
        self.view = QuoteConfigurationSelectableItem(title: title, type: type, tag: tag, isInitialIndex: isInitialIndex)

        super.init(info: view.info, radioTable: radio, privateComponent)
    }
}
