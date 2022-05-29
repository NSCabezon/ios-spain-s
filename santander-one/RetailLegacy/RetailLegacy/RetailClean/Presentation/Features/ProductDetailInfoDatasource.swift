import UIKit

protocol ProductDetailInfoDataSourceDelegate: class {
    func edit()
    func endEditing(withNewAlias alias: String?)
}

class ProductDetailInfoDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var items: [TableModelViewSection]
    weak var delegate: ProductDetailInfoDataSourceDelegate?
    weak var toolTipDelegate: ToolTipDisplayer?
    
    init(items: [TableModelViewSection]) {
        self.items = items
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = items[section]
        return section.rowsCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = items[indexPath.section]
        let item = section.get(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: item!.identifier, for: indexPath) as! BaseViewCell
        if let item = item {
            item.bind(viewCell: cell)
        }
        if var cell = cell as? ProductDetailCell {
            cell.editDelegate = delegate
        }
        if let cell = cell as? ChangeAliasTableViewCell {
            cell.editDelegate = delegate
        }
        
        if let cell = cell as? ToolTipCompatible {
            cell.toolTipDelegate = toolTipDelegate
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let item = items[indexPath.section].get(indexPath.row)
        return item?.height ?? UITableView.automaticDimension
    }
}
