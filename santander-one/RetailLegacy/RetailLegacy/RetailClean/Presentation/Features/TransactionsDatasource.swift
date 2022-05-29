//

import UIKit

class TransactionsDataSource: NSObject, UITableViewDataSource {
    
    private(set) var sections = [TableModelViewSection]()
    weak var toolTipDelegate: ToolTipDisplayer?
    
    func addSections(_ sections: [TableModelViewSection]) {
        self.sections.append(contentsOf: sections)
    }
    
    func removeSection(_ index: Int) {
        if index < self.sections.count && index >= 0 {
            self.sections.remove(at: index)
        }
    }
    
    func insertSection(_ section: TableModelViewSection, at index: Int) {
        self.sections.insert(section, at: index)
    }
    
    func replaceAllSections(_ sections: [TableModelViewSection]) {
        self.sections = sections
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionViewModel = sections[indexPath.section]
        let item = sectionViewModel.get(indexPath.row)
        guard let identifier = item?.identifier, let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BaseViewCell else {
            // Returning empty cell because before fatal error broke the app
            return tableView.dequeueReusableCell(withIdentifier: "VeryEmptyViewCell", for: indexPath)
        }
        cell.indexPath = indexPath
        item?.bind(viewCell: cell)
        if let cell = cell as? ToolTipCompatible {
            cell.toolTipDelegate = toolTipDelegate
        }
        return cell
    }
    
}
