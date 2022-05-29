//
//  SendMoneyAccountSelectorViewController.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import UIKit
import Operative
import UI
import UIOneComponents
import CoreFoundationLib

protocol SendMoneyAccountSelectorView: OperativeView {
    func setSections(to sections: [SendMoneyAccountSelectorSection])
    func showHiddenAccountsWarning()
}

final class SendMoneyAccountSelectorViewController: UIViewController {

    let presenter: SendMoneyAccountSelectorPresenterProtocol
    @IBOutlet private weak var tableView: UITableView!
    private var sections: [SendMoneyAccountSelectorSection] = []
    
    private lazy var headerView: SendMoneyAccountSelectorHeaderView = {
        let headerView = SendMoneyAccountSelectorHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    init(presenter: SendMoneyAccountSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "SendMoneyAccountSelectorViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
        self.setupNavigationBar()
        self.tableView.updateHeaderViewFrame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setAccessibility(setViewAccessibility: self.setAccesibilityInfo)
    }
}

extension SendMoneyAccountSelectorViewController: SendMoneyAccountSelectorView {
    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
    
    func setSections(to sections: [SendMoneyAccountSelectorSection]) {
        self.sections = sections
        self.tableView.reloadData()
    }
    
    func showHiddenAccountsWarning() {
        self.headerView.shouldShowAlert(true)
    }
}

extension SendMoneyAccountSelectorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sections[indexPath.section].cell(in: tableView, for: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
}

extension SendMoneyAccountSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .visible(let accounts), .hidden(let accounts, _):
            self.presenter.didSelectAccount(accounts[indexPath.item])
        case .showHidden:
            self.expandHidden()
        }
    }
}

private extension SendMoneyAccountSelectorViewController {
    func setupTableView() {
        self.tableView.register(SendMoneyAccountSelectorCell.self, bundle: SendMoneyAccountSelectorCell.bundle)
        self.tableView.register(AccountSelectorShowMoreCell.self, bundle: AccountSelectorShowMoreCell.bundle)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.setTableHeaderView(headerView: self.headerView)
    }
    
    func expandHidden() {
        var hiddenAccountsIsExpanded = false
        sections = sections.map {
            guard case .hidden(let accounts, let isExpanded) = $0 else { return $0 }
            hiddenAccountsIsExpanded = !isExpanded
            return .hidden(accounts, isExpanded: !isExpanded)
        }
        guard let index = self.getNotVisibleAccountsSection() else { return }
        self.tableView.beginUpdates()
        self.tableView.reloadSections([index], with: .automatic)
        self.tableView.endUpdates()
        if UIAccessibility.isVoiceOverRunning {
            self.changeAccountFocus(hiddenAccountsIsExpanded: hiddenAccountsIsExpanded, sectionIndex: index)
        }
    }
    
    func setupNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_originAccount")
            .setLeftAction(.back, customAction: self.presenter.back)
            .setRightAction(.help, action: {
                Toast.show(localized("generic_alert_notAvailableOperation"))
            })
            .setRightAction(.close, action: {
                self.presenter.close()
            })
            .setLeftAction(.back)
            .setAccessibilityTitleLabel(withKey: "toolbar_title_originAccount")
            .build(on: self)
    }
    
    func getNotVisibleAccountsSection() -> Int? {
        if let index = sections.firstIndex( where: { if case .hidden = $0 { return true } else { return false } }) {
            return Int(index)
        } else {
            return nil
        }
    }
    
    func setAccesibilityInfo() {
        UIAccessibility.post(notification: .layoutChanged, argument: self.navigationItem.titleView)
    }
    
    func changeAccountFocus(hiddenAccountsIsExpanded: Bool, sectionIndex: Int) {
        if hiddenAccountsIsExpanded {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: sectionIndex), at: .top, animated: false)
            let showMoreCellIndex = self.getShowMoreCellIndex()
            if showMoreCellIndex < self.tableView.visibleCells.count - 1 {
                UIAccessibility.post(notification: .screenChanged, argument: self.tableView.visibleCells[self.getShowMoreCellIndex() + 1])
            }
        } else {
            UIAccessibility.post(notification: .screenChanged, argument: self.tableView.visibleCells[self.getShowMoreCellIndex() - 1])
        }
    }
    
    func getShowMoreCellIndex() -> Int {
        guard let index = self.tableView.visibleCells.firstIndex(where: {
            guard let _ = $0 as? AccountSelectorShowMoreCell else { return false }
            return true
        }) else { return 0 }
        return index
    }
}

extension SendMoneyAccountSelectorViewController: AccessibilityCapable {}
