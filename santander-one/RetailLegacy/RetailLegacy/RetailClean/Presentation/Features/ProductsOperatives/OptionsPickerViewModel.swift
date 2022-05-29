//

import Foundation

class OptionsPickerViewModel<Element: CustomStringConvertible>: TableModelViewItem<OptionsPickerTableViewCell> {
    
    // MARK: Private attributes
    
    private var selected: Element?
    private let items: [Element]
    private let completion: (Element) -> Void
    private let cellIdentifier: String?
    
    // MARK: - Public methods
    
    init(items: [Element], selected: Element? = nil, dependencies: PresentationComponent, cellIdentifier: String? = nil ,completion: @escaping (Element) -> Void) {
        self.items = items
        self.completion = completion
        self.selected = selected ?? items.first
        self.cellIdentifier = cellIdentifier
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: OptionsPickerTableViewCell) {
        viewCell.pickerDelegateAndDataSource = OptionsPickerDelegateAndDataSource(options: items.map({ localized($0.description).text })) { [weak self] selected in
            guard let strongSelf = self else { return }
            strongSelf.selected = strongSelf.items[selected]
            viewCell.textField.set(localizedStylableText: strongSelf.localized(strongSelf.items[selected].description))
            strongSelf.completion(strongSelf.items[selected])
        }
        viewCell.setIdentifier(self.cellIdentifier)
        viewCell.textField.set(localizedStylableText: localized(selected?.description ?? ""))
        let position = items.map({ return $0.description }).firstIndex(of: selected?.description ?? "")
        viewCell.setSelected(option: selected?.description ?? "", position: position ?? 0)
    }
    
    // MARK: - Private methods
    
    private func localized(_ key: String) -> LocalizedStylableText {
        return dependencies.stringLoader.getString(key)
    }
}
