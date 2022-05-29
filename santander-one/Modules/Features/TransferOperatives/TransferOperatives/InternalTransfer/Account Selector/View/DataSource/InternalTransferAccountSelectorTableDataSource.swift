//
//  InternalTransferAccountSelectorTableDataSource.swift
//  TransferOperatives
//
//  Created by Mario Rosales Maillo on 16/2/22.
//

import Foundation
import CoreFoundationLib
import OpenCombine

final class InternalTransferAccountSelectorTableDataSource: NSObject {    
    let didSelectRowAtSubject = PassthroughSubject<OneAccountSelectionCardItem, Never>()
    let expandHidden = PassthroughSubject<(Bool, Int?), Never>()
    public var sections: [InternalTransferAccountSelectorSection] = []
}

extension InternalTransferAccountSelectorTableDataSource: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sections[indexPath.section].cell(in: tableView, for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .visible(let accounts), .hidden(let accounts, _):
            clearSelectedAccount()
            accounts[indexPath.item].cardStatus = .selected
            didSelectRowAtSubject.send(accounts[indexPath.item])
        case .showHidden:
            var expanded = false
            sections = sections.map {
                guard case .hidden(let accounts, let isExpanded) = $0 else { return $0 }
                expanded = !isExpanded
                return .hidden(accounts, isExpanded: !isExpanded)
            }
            self.expandHidden.send((expanded, getNotVisibleAccountsSection()))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section == sections.count - 1 else { return 0 }
        return paddingForLastCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 27))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }
}

private extension InternalTransferAccountSelectorTableDataSource {
    var paddingForLastCell: CGFloat {
        return 27.0
    }
    
    func getNotVisibleAccountsSection() -> Int? {
        return sections.firstIndex( where: { if case .hidden = $0 { return true } else { return false } })
    }
    
    func getVisibleAccountsSection() -> Int? {
        return sections.firstIndex( where: { if case .visible = $0 { return true } else { return false } })
    }
    
    func clearSelectedAccount() {
        if let visibleIndex = getVisibleAccountsSection() {
            sections[visibleIndex].clearSelection()
        }
        if let hiddenIndex = getNotVisibleAccountsSection() {
            sections[hiddenIndex].clearSelection()
        }
    }
}
