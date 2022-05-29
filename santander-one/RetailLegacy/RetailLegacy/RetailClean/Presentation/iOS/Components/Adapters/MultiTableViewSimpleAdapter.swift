import UIKit

class MultiTableViewSimpleAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {

    var items = [TableModelViewItem<BaseViewCell>]()
    var table: UITableView

    init(table: UITableView) {
        self.table = table
        super.init()
        table.dataSource = self
        table.delegate = self
    }

    func add <T> (cell: TableModelViewItem<T>) {
        add(cell: cell, index: items.count)
    }

    func add <T> (cell: TableModelViewItem<T>, index: Int) {
        guard table.dequeueReusableCell(withIdentifier: cell.identifier) != nil,
            let castedCell = cell as? TableModelViewItem<BaseViewCell> else {
            table.register(T.self, forCellReuseIdentifier: cell.identifier)
            return
        }
        items[index] = castedCell
        table.reloadRows(at: [IndexPath(index: index)], with: UITableView.RowAnimation.automatic)
    }

    func addAll <T> (cells: [TableModelViewItem<T>], indexRow: Int) {
        var insertedIndexCell = indexRow
        for cell in cells {
            add(cell: cell, index: insertedIndexCell)
            insertedIndexCell += 1
        }
    }

    func addAll <T> (cells: [TableModelViewItem<T>]) {
        for cell in cells {
            if let cell = cell as? TableModelViewItem<BaseViewCell> {
                add(cell: cell)
            }
        }
    }

    func indexOf<T>(item: TableModelViewItem<T>) -> Int {
        guard let items = items as? [TableModelViewItem<T>] else { return -1 }
        return items.firstIndex(of: item) ?? -1
    }
    
    func get<T>(index: Int) -> TableModelViewItem <T>? {
        guard let cell = items[index] as? TableModelViewItem <T> else { return nil }
        return cell
    }
    
    func getCells<T>() -> [TableModelViewItem<T>]? {
        guard let cells = items as? [TableModelViewItem <T>] else { return nil }
        return cells
    }
    
    func remove<T>(cell: TableModelViewItem<T>) {
        let index = indexOf(item: cell)
        if index > 0 {
            remove(index: index)
        }
    }

    func remove(index: Int) {
        items.remove(at: index)
        table.reloadRows(at: [IndexPath(index: index)], with: .automatic)
    }

    func removeAll<T>(cells: [TableModelViewItem<T>]) {
        for cell in cells {
            remove(cell: cell)
        }
    }

    func update<T>(cell: TableModelViewItem<T>, index: Int) {
        if let cell = cell as? TableModelViewItem<BaseViewCell> {
            items[index] = cell
            table.reloadRows(at: [IndexPath(index: index)], with: .automatic)
        }
        
    }

    func clean() {
        items.removeAll()
        table.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewCell = table.dequeueReusableCell(withIdentifier: items[indexPath.row].identifier) as? BaseViewCell else {
            return BaseViewCell()
        }
        items[indexPath.row].bind(viewCell: viewCell)
        return viewCell
    }

}
