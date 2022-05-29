import CoreFoundationLib

protocol ItemDetailViewProtocol: class {
    func update(with viewModel: ItemDetailViewModel)
}

final class ItemDetailViewModel {
    let title: TextWithAccessibility
    let value: TextWithAccessibility?
    var info: TextWithAccessibility?
    
    public init(title: TextWithAccessibility, value: TextWithAccessibility? = nil, info: TextWithAccessibility? = nil) {
        self.title = title
        self.value = value
        self.info = info
    }
    
    func setup(_ view: ItemDetailViewProtocol) {
        view.update(with: self)
    }

    func setTitleAccessibility(_ value: String) {
        self.title.setAccessibility(value)
    }

    func setValueAccessibility(_ value: String) {
        self.value?.setAccessibility(value)
    }
    func setInfoAccessibility(_ value: String) {
        self.info?.setAccessibility(value)
    }
    
    func removeInfo() {
        self.info = nil
    }
}
