//

import UIKit

protocol ProductHomeDialogDelegate: class {
    
    func getIndex(_ index: Int)
}

class ProductHomeDialogDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var items: [ProductOption]
    var cellIdentifier: String
    weak var delegate: ProductHomeDialogDelegate?
    var stringLoader: StringLoader
    
    init(items: [ProductOption], cellIdentifier: String, stringLoader: StringLoader) {
        self.items = items
        self.cellIdentifier = cellIdentifier
        self.stringLoader = stringLoader
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProductHomeDialogViewCell
        cell.configOptionCell(items[indexPath.row])
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = ProductHomeDialogHeaderView()
        tableView.removeUnnecessaryHeaderTopPadding()
        return headerView.sectionHeader(stringLoader.getString("productOption_text_moreOperations"), width: tableView.contentSize.width)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        delegate?.getIndex(items[indexPath.row].index)
    }
}
