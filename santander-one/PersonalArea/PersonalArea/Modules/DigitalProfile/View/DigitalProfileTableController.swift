import CoreFoundationLib
import CoreDomain

protocol DigitalProfileTableCellProtocol {
    func setCellDelegate(delegate: DigitalProfileTableDelegate?)
}

protocol DigitalProfileTableDelegate: AnyObject {
    func didSelect(item: DigitalProfileElemProtocol)
    func didSwipe()
}

struct CellInfoDigitalProfile {
    let cellClass: String
    let cellHeight: CGFloat
    let info: Any?
    let item: DigitalProfileElemProtocol?
}

final class DigitalProfileTableController: NSObject, UITableViewDelegate, UITableViewDataSource {
    weak var controlledTableView: UITableView?
    weak var delegate: DigitalProfileTableDelegate?
    var cellsInfo: [CellInfoDigitalProfile] = [] {
        didSet {
            registerCells()
            controlledTableView?.reloadData()
            controlledTableView?.setNeedsLayout()
        }
    }
    
    init(tableView: UITableView?) {
        super.init()
        self.controlledTableView = tableView
        
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
    func setInfo(configured: [DigitalProfileElemProtocol], notConfigured: [DigitalProfileElemProtocol]) {
        var result: [CellInfoDigitalProfile] = []
        var notConfiguredCarruselItems: [DigitalProfileElemProtocol] = []
        var notConfiguredListItems: [DigitalProfileElemProtocol] = []
        notConfigured.forEach {
            if notConfiguredCarruselItems.count < 3 {
                notConfiguredCarruselItems.append($0)
            }
            notConfiguredListItems.append($0)
        }
        if !notConfiguredCarruselItems.isEmpty {
            result.append(CellInfoDigitalProfile(cellClass: "DigitalProfileCarrouselTableViewCell",
                                                 cellHeight: 160.0,
                                                 info: DigitalProfileCarrouselCellModel(title: localized("digitalProfile_title_configApp"),
                                                                                        titleNum: "(\(notConfigured.count)/\(notConfigured.count + configured.count))",
                                                                                        cells: notConfiguredCarruselItems,
                                                                                        titleAccassibilityIdentifier: "digitalProfile_title_configApp",
                                                                                        titleNumAccassibilityIdentifier: "digitalProfile_titleNum_configApp"), item: nil))
        }
        if !notConfiguredListItems.isEmpty {
            result.append(CellInfoDigitalProfile(cellClass: "DigitalProfileHeaderTableViewCell",
                                                 cellHeight: 65.0,
                                                 info: DigitalProfileCellModel(title: localized("digitalProfile_title_without"),
                                                                               done: false,
                                                                               accassibilityIdentifier: "digitalProfile_title_without"), item: nil))
            result.append(contentsOf: notConfiguredListItems.map {
                CellInfoDigitalProfile(cellClass: "DigitalProfileOptionTableViewCell",
                                       cellHeight: 48.0,
                                       info: DigitalProfileCellModel(title: $0.title(),
                                                                     done: false,
                                                                     accassibilityIdentifier: $0.accessibilityIdentifier(state: "pending")),
                                       item: $0)
            })
        }
        if !configured.isEmpty {
            result.append(CellInfoDigitalProfile(cellClass: "DigitalProfileHeaderTableViewCell",
                                                 cellHeight: 65.0,
                                                 info: DigitalProfileCellModel(title: localized("digitalProfile_title_with"),
                                                                               done: true,
                                                                               accassibilityIdentifier: "digitalProfile_title_with"),
                                                 item: nil))
            result.append(contentsOf: configured.map {
                CellInfoDigitalProfile(cellClass: "DigitalProfileOptionTableViewCell",
                                       cellHeight: 48.0,
                                       info: DigitalProfileCellModel(title: $0.title(),
                                                                     done: true,
                                                                     accassibilityIdentifier: $0.accessibilityIdentifier(state: "completed")),
                                       item: nil)
            })
        }
        cellsInfo = result
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { cellsInfo.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = cellsInfo[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellInfo.cellClass, for: indexPath)
        (cell as? GeneralPersonalAreaCellProtocol)?.setCellInfo(cellInfo.info)
        (cell as? DigitalProfileTableCellProtocol)?.setCellDelegate(delegate: self.delegate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let section = cellsInfo[indexPath.row].item {
            delegate?.didSelect(item: section)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        cellsInfo[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 0.0 }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 0.0 }
    
    private func registerCells() {
        cellsInfo.forEach { controlledTableView?.register(UINib(nibName: $0.cellClass,
                                                                bundle: Bundle.module),
                                                          forCellReuseIdentifier: $0.cellClass) }
    }
}
