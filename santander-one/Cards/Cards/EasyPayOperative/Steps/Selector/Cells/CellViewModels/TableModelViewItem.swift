//
//  TableModelViewItem.swift
//  Cards
//
//  Created by alvola on 14/12/2020.
//

protocol EasyPayTableViewCellProtocol: UITableViewCell {
    var identifier: String {get}
    var accessibilityIdentifier: String? { get set }
    func setCellInfo(_ info: Any)
}

extension EasyPayTableViewCellProtocol {
    var identifier: String {
        return String(describing: self)
    }
}

protocol EasyPayTableViewModelProtocol {
    var identifier: String {get}
}

final class EasyPayTableModelViewSection {
    
    var items = [EasyPayTableViewModelProtocol]()
    
    var identifier: String {
        return String(describing: self)
    }
    
    var rowsCount: Int {
        return items.count
    }
    
    var isCollapsible: Bool = false
    
    var isCollapsed: Bool = false
    
    var isFeatured: Bool = false
    
    var isHighlighted: Bool = false
    
    func getItems() -> [Any]? {
        guard !items.isEmpty else { return nil }
        return items.map { $0 }
    }
    
    func get(_ index: Int) -> Any? {
        guard index < items.count else { return nil }
        return items[index]
    }
    
    func add(item: EasyPayTableViewModelProtocol) {
        add(item: item, index: items.count)
    }
    
    func add(item: EasyPayTableViewModelProtocol, index: Int) {
        items.insert(item, at: index)
    }
    
    func add(items: [EasyPayTableViewModelProtocol]) {
        self.items += items
    }
    
    func remove(index: Int) {
        items.remove(at: index)
    }
    
    func removeAll() {
        items.removeAll()
    }
}
