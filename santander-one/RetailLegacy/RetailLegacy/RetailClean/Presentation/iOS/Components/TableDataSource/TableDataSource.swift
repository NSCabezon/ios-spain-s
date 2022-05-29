import UIKit
import CoreFoundationLib

protocol TableDataSourceDelegate: class {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
}

extension TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
}

class TableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private(set) var sections = [TableModelViewSection]()
    weak var delegate: TableDataSourceDelegate?
    private var registeredCells: [String] = []
    private var registeredHeaderFooter: [String] = []
    weak var toolTipDelegate: ToolTipDisplayer?

    func addSections(_ sections: [TableModelViewSection]) {
        self.sections.append(contentsOf: sections)
    }
    
    func addSections(_ sections: [TableModelViewSection], registeringCellsIn tableView: UITableView) {
        self.sections.append(contentsOf: sections)
        sections.forEach { section in
            if let headerIdentifier = section.getHeader()?.identifier, !registeredHeaderFooter.contains(headerIdentifier) {
                tableView.register(UINib(nibName: headerIdentifier, bundle: .module), forHeaderFooterViewReuseIdentifier: headerIdentifier)
                registeredHeaderFooter.append(headerIdentifier)
            }
            section.getItems()?.forEach { item in
                if !registeredCells.contains(item.identifier) {
                    tableView.register(UINib(nibName: item.identifier, bundle: .module), forCellReuseIdentifier: item.identifier)
                    registeredCells.append(item.identifier)
                }
            }
        }
    }
    
    func clearSections() {
        self.sections.removeAll()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = sections[section].getHeader(),
            let viewCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: header.identifier) else { return nil }
        guard let baseViewHeader = viewCell as? BaseViewHeader else { return nil }
        header.bind(viewHeader: baseViewHeader)
        tableView.removeUnnecessaryHeaderTopPadding()
        return viewCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !sections.isEmpty else {
            return 0
        }
        if let header = sections[section].getHeader() {
            return header.height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionViewModel = sections[indexPath.section]
        let item = sectionViewModel.get(indexPath.row)
        guard let identifier = item?.identifier, let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BaseViewCell else {
            fatalError("Cell identifier is invalid or cell is not BaseViewCell")
        }
        cell.accessibilityIdentifier = item?.accessibilityIdentifier
        cell.indexPath = indexPath
        cell.frame.size.width = tableView.frame.size.width
        item?.bind(viewCell: cell)
        if let cell = cell as? ToolTipCompatible {
            cell.toolTipDelegate = toolTipDelegate
        }
        let cellWithAccessibilityIdentifiers = getCellWithAccessibilityIdentifiers(cell, index: indexPath.row)
        return cellWithAccessibilityIdentifiers
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = sections[indexPath.section].get(indexPath.row)
        
        return item?.height ?? UITableView.automaticDimension
    }
    
    @objc
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.tableView(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
}

private extension TableDataSource {
    func getCellWithAccessibilityIdentifiers(_ cell: BaseViewCell, index: Int) -> BaseViewCell {
        switch cell {
        case (let generic as GenericConfirmationTableViewCell):
            generic.setAccessibilityIdentifiers(identifiers: ( AccessibilityTransferHistorical.nameLabelGenericConfirmationCell,
                                                 AccessibilityTransferHistorical.identifierLabelGenericConfirmationCell,
                                                 AccessibilityTransferHistorical.amountLabelGenericConfirmationCell,
                                                 AccessibilityTransferHistorical.amountInfoLabelGenericConfirmationCell))
            return generic
        case (let detailThreeLines as DetailThreeLinesTableViewCell):
            detailThreeLines.setAccessibilityIdentifiers(titleAccessibilityIdentifier: AccessibilityTransferHistorical.titleLabelDetailThreeLinesCell,                                                                      amountAccessibilityIdentifier: AccessibilityTransferHistorical.amountLabelDetailThreeLinesCell,
                                                         descriptionAccessibilityIdentier: AccessibilityTransferHistorical.descriptionLabelDetailThreeLinesCell)
            return detailThreeLines
        case (let detailItem as DetailItemTableViewCell):
            detailItem.setAccessibilityIdentifiers(titleAccessibilityIdentifier: "\(AccessibilityTransferHistorical.titleLabelDetailItemCell)_\(index)",
                                                   subtitleAccessibilityIdentifier: "\(AccessibilityTransferHistorical.subtitleLabelDetailItemCell)_\(index)",
                                                   copyButtonAccessibilityIdentifier: "\(AccessibilityTransferHistorical.btnCopyDetailItemCell)_\(index)",
                                                   imgCopyButtonAccessibilityIdentifier: "\(AccessibilityTransferHistorical.imgBtnCopyDetailItemCell)_\(index)")
            return detailItem
        default:
            return cell
        }
    }
}
