class OptionsPickerStackModel<Element: CustomStringConvertible>: StackItem<OptionsPickerStackView> {
    private var selected: Element?
    private let items: [Element]
    private let completion: (Element) -> Void
    private let dependencies: PresentationComponent
    
    // MARK: - Public methods
    
    init(items: [Element], selected: Element? = nil, dependencies: PresentationComponent, insets: Insets = Insets(left: 10, right: 10, top: 0, bottom: 8), completion: @escaping (Element) -> Void) {
        self.items = items
        self.completion = completion
        self.selected = selected ?? items.first
        self.dependencies = dependencies
        super.init(insets: insets)
    }
    
    override func bind(view: OptionsPickerStackView) {
        view.textField.set(localizedStylableText: localized(selected?.description ?? ""))
        
        let pickerDelegateAndDataSource = OptionsPickerDelegateAndDataSource(options: items.map({ localized($0.description).text })) { [weak self] selected in
            guard let strongSelf = self else { return }
            strongSelf.selected = strongSelf.items[selected]
            view.textField.set(localizedStylableText: strongSelf.localized(strongSelf.items[selected].description))
            strongSelf.completion(strongSelf.items[selected])
        }
        var index = 0
        if let selected = selected {
            index = items.firstIndex(where: { $0.description == selected.description }) ?? 0
        }
        view.setPickerDelegateAndDataSource(pickerDelegateAndDataSource, selectedRow: index)
    }
    
    // MARK: - Private methods
    
    private func localized(_ key: String) -> LocalizedStylableText {
        return dependencies.stringLoader.getString(key)
    }
}
