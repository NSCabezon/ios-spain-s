//
//  PersonalAreaTableViewController.swift
//  PersonalArea
//
//  Created by alvola on 11/11/2019.
//

import Foundation
import CoreFoundationLib
import OpenCombine

protocol GeneralPersonalAreaCellProtocol {
    func setCellInfo(_ info: Any?)
}

protocol WillDisplayCellActionble {
    func willDisplay()
}

protocol PersonalAreaActionCellProtocol {
    func setCellDelegate(_ delegate: PersonalAreaActionCellDelegate?, action: PersonalAreaAction?)
}

protocol PersonalAreaCustomActionCellProtocol {
    func setCustomActionCellDelegate(_ delegate: PersonalAreaCustomActionCellDelegate?, action: CustomAction?)
}

protocol PersonalAreaActionCellDelegate: AnyObject {
    func valueDidChange(_ action: PersonalAreaAction, value: Any)
}

protocol PersonalAreaCustomActionCellDelegate: AnyObject {
    func valueDidChange(_ action: @escaping CustomAction, value: Any)
    func didSelect(_ action: @escaping CustomAction)
}

protocol PersonalAreaTableViewControllerDelegate: AnyObject {
    func didSelect(_ section: PersonalAreaSection)
}

protocol PersonalAreaTableViewControllerProtocol {
    var cellsInfo: [PersonalAreaCellInfoRepresentable] { get set }
    func setDelegate(_ delegate: (PersonalAreaTableViewControllerDelegate & PersonalAreaActionCellDelegate)?)
    func setCustomDelegate(_ delegate: PersonalAreaCustomActionCellDelegate?)
}

class PersonalAreaTableViewController: NSObject, PersonalAreaTableViewControllerProtocol, UITableViewDelegate, UITableViewDataSource {
    
    weak var controlledTableView: UITableView?
    
    weak var delegate: (PersonalAreaTableViewControllerDelegate & PersonalAreaActionCellDelegate)?
    weak var customActiondelegate: PersonalAreaCustomActionCellDelegate?
    
    var cellsInfo: [PersonalAreaCellInfoRepresentable] = [] {
        didSet {
            registerCells()
            controlledTableView?.reloadData()
        }
    }
    
    init(tableView: UITableView?) {
        super.init()
        self.controlledTableView = tableView
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
    func setDelegate(_ delegate: (PersonalAreaTableViewControllerDelegate & PersonalAreaActionCellDelegate)?) {
        self.delegate = delegate
    }
    
    func setCustomDelegate(_ delegate: PersonalAreaCustomActionCellDelegate?) {
        self.customActiondelegate = delegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = cellsInfo[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellInfo.cellClass, for: indexPath)
        
        (cell as? GeneralPersonalAreaCellProtocol)?.setCellInfo(cellInfo.info)
        (cell as? PersonalAreaActionCellProtocol)?.setCellDelegate(delegate, action: cellInfo.action)
        (cell as? PersonalAreaCustomActionCellProtocol)?.setCustomActionCellDelegate(customActiondelegate, action: cellInfo.customAction)
        (cell as? GeneralSectionTableViewCell)?.setCellSubsectionDelegateIfNeeded(self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? WillDisplayCellActionble)?.willDisplay()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let section = cellsInfo[indexPath.row].goToSection {
            delegate?.didSelect(section)
        }
        guard let action = self.cellsInfo[indexPath.row].customAction else { return }
        self.customActiondelegate?.didSelect(action)
    }
    
    private func registerCells() {
        cellsInfo.forEach { [weak self] in
            self?.controlledTableView?.register(UINib(nibName: $0.cellClass, bundle: Bundle.module), forCellReuseIdentifier: $0.cellClass)
        }
    }
    
    func didSelect(_ section: PersonalAreaSection) { delegate?.didSelect(section) }
}

extension PersonalAreaTableViewController: CellSubsectionProtocol {
    func didSelectCellSubsection(_ cellSubsection: PersonalAreaSection) {
        didSelect(cellSubsection)
    }
}

final class ReactivePersonalAreaTableViewController: PersonalAreaTableViewController {
    let didSelectSectionSubject = PassthroughSubject<PersonalAreaSection, Never>()
    let didSelectCustomActionSubject = PassthroughSubject<CustomAction, Never>()
    let didChangeValueActionSubject = PassthroughSubject<(action: PersonalAreaAction, value: Any), Never>()
    let didChangeValueCustomActionSubject = PassthroughSubject<(customAction: CustomAction, value: Any?), Never>()
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = cellsInfo[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellInfo.cellClass, for: indexPath)
        (cell as? GeneralPersonalAreaCellProtocol)?.setCellInfo(cellInfo.info)
        (cell as? PersonalAreaActionCellProtocol)?.setCellDelegate(self, action: cellInfo.action)
        (cell as? PersonalAreaCustomActionCellProtocol)?.setCustomActionCellDelegate(self, action: cellInfo.customAction)
        (cell as? GeneralSectionTableViewCell)?.setCellSubsectionDelegateIfNeeded(self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let section = cellsInfo[indexPath.row].goToSection {
            self.didSelectSectionSubject.send(section)
        }
        guard let action = self.cellsInfo[indexPath.row].customAction else { return }
        self.didSelectCustomActionSubject.send(action)
    }
    
    override func didSelect(_ section: PersonalAreaSection) {
        self.didSelectSectionSubject.send(section)
    }
}

extension ReactivePersonalAreaTableViewController: PersonalAreaActionCellDelegate {
    func valueDidChange(_ action: PersonalAreaAction, value: Any) {
        self.didChangeValueActionSubject.send((action, value))
    }
}

extension  ReactivePersonalAreaTableViewController: PersonalAreaCustomActionCellDelegate {
    func valueDidChange(_ action: @escaping CustomAction, value: Any) {
        self.didChangeValueCustomActionSubject.send((customAction: action, value: value))
    }
    
    func didSelect(_ action: @escaping CustomAction) {
        self.didChangeValueCustomActionSubject.send((customAction: action, value: nil))
    }
}
