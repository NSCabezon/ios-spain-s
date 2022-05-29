import Foundation

class TableModelViewSection: NSObject {
    
    var items = [AnyObject]()
    private var header: AnyObject?
    private var footer: AnyObject?
    
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

    var isInnerTitle: Bool = false
    
    func getItems() -> [TableModelViewProtocol]? {
        guard !items.isEmpty else { return nil }
        return items as? [TableModelViewProtocol]
    }
    
    func get(_ index: Int) -> TableModelViewProtocol? {
        guard index < items.count else { return nil }
        return items[index] as? TableModelViewProtocol
    }
    
    func setHeader<T>(modelViewHeader: TableModelViewHeader<T>) {
        modelViewHeader.section = self
        header = modelViewHeader
    }
    
    func removeHeader() {
        header = nil
    }
    
    func getHeader() -> TableModelViewHeaderProtocol? {
        return header as? TableModelViewHeaderProtocol
    }
    
    func setFooter<T>(modelViewFooter: TableModelViewHeader<T>) {
        modelViewFooter.section = self
        footer = modelViewFooter
    }
    
    func getFooter() -> TableModelViewHeaderProtocol? {
        return footer as? TableModelViewHeaderProtocol
    }
    
    func add <T> (item: TableModelViewItem<T>) {
        add(item: item, index: items.count)
    }
    
    func add<T>(item: TableModelViewItem<T>, index: Int) {
        item.section = self
        items.insert(item, at: index)
    }
    
    func addAll<T>(items: [TableModelViewItem<T>], index: Int) {
        var insertedIndexCell = index
        for item in items {
            add(item: item, index: insertedIndexCell)
            insertedIndexCell += 1
        }
    }
    
    func addAll<T>(items: [TableModelViewItem<T>]) {
        for item in items {
            add(item: item)
        }
    }
    
    func indexOf<T>(_ cell: TableModelViewItem<T>) -> Int {
        return items.firstIndex(where: { ($0 as? NSObject) == cell }) ?? -1
    }
    
    func remove<T>(cell: TableModelViewItem<T>) {
        let index = indexOf(cell)
        if index >= 0 {
            remove(index: index)
        }
    }
    
    func remove(index: Int) {
        items.remove(at: index)
    }
    
    func update<T>(item: TableModelViewItem<T>, index: Int) {
        if let item = item as? TableModelViewItem<BaseViewCell> {
            items[index] = item
        }
    }
    
    func moveItemAt(position: Int, to destinationPosition: Int) {
        let item = items.remove(at: position)
        items.insert(item, at: destinationPosition)
    }
    
    func clean() {
        items.removeAll()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TableModelViewSection else { return false }
        return identifier == rhs.identifier
    }
    
    func setItemsRounded() {
        let lastIndex = (self.getItems()?.count ?? 0) - 1
        getItems()?.map { $0 as? GroupableCell }.enumerated().forEach { index, item in
            item?.isFirst = index == 0
            item?.isLast = index == lastIndex
            item?.isSeparatorVisible = item?.isLast == false
        }
    }
}
