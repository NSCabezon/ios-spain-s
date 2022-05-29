class RadioButtonStackModel<T: RadioButtonStackView>: StackItem<T>, RadioButtonSelectable {
    private let title: LocalizedStylableText
    var isSelected: Bool
    var valueAction: (() -> Void)?
    private var udpateAction: ((Bool) -> Void)?
    
    init(title: LocalizedStylableText, isSelected selected: Bool, insets: Insets = Insets(left: 11, right: 11, top: 15, bottom: 6)) {
        self.title = title
        self.isSelected = selected
        super.init(insets: insets)
    }
    
    override func bind(view: T) {
        view.title = title
        view.setMarked(isMarked: isSelected)
        view.valueAction = valueAction
        udpateAction = view.udpateAction
    }
    
    func updateMarked(value: Bool) {
        if value != isSelected {
            isSelected = value
            udpateAction?(value)
        }
    }
}
