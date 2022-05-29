class ChargeDischargeViewModel: RadioTableModelView {
    
    let view: ChargeDischargeRadioSelectorView
    
    init(title: LocalizedStylableText, type: OrderTypeItemType, tag: Int, radio: RadioTable, isInitialIndex: Bool, privateComponent: PresentationComponent, onTextChangeDelegate: OnRadioItemTextChangeDelegate?) {
        self.view = ChargeDischargeRadioSelectorView(title: title, type: type, tag: tag, isInitialIndex: false, onTextChangeDelegate: onTextChangeDelegate)
        
        super.init(info: view.info, radioTable: radio, privateComponent)
    }
}
