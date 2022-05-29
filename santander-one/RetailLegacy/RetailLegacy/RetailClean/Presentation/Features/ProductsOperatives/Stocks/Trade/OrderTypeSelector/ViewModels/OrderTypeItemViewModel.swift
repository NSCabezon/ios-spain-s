enum OrderTypeItemType {
    case empty
    case amount(placeholder: LocalizedStylableText, value: String?)
}

class OrderTypeItemViewModel: RadioTableModelView {
    
    let type: OrderTypeItemType
    let view: OrderTypeRadioSelectableItem
    
    init(title: LocalizedStylableText, type: OrderTypeItemType, tag: Int, radio: RadioTable, isInitialIndex: Bool, privateComponent: PresentationComponent) {
        self.type = type
        self.view = OrderTypeRadioSelectableItem(title: title, type: type, tag: tag, isInitialIndex: false)
        
        super.init(info: view.info, radioTable: radio, privateComponent)
    }
}
