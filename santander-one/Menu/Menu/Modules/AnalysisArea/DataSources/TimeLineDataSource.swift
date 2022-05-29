//
//  TimeLineDataSource.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 23/03/2020.
//

import UI
import CoreFoundationLib

private let timelineMovementCellIdentifier = "timelineMovementCellIdentifier"
private let timelineReducedDebtCellIdentifier = "reducedDebtCellIdentifier"

final class TimeLineDataSource: NSObject {

    private var activeMonth: String? {
        willSet {
            guard let optionalValue = newValue else {
                return
            }
            self.items = self.timeLineViewModel?.getDataForMonth(optionalValue)
        }
    }
    
    private var items: [ExpenseItem]? {
        didSet {
            itemsSource.removeAll()
            if let itemSection = items?.filter({$0.expenseType == .reducedDebt}).first {
                itemsSource.append([itemSection])
            }
            if let section = items?.filter({$0.expenseType != .reducedDebt}) {
                itemsSource.append(section)
            }
        }
    }

    private var itemsSource: [[ExpenseItem]] = [[ExpenseItem]]()
    private var timeLineViewModel: TimeLineViewModel?
    
    func setActiveMonth(_ activeMonth: String) {
        self.activeMonth = activeMonth
    }
    
    func registerCellsFor(_ tableView: UITableView) {
        let movementsNibName = UINib(nibName: "TimeLineMovementCell", bundle: .module)
        let reducedNibName = UINib(nibName: "ReducedDebtCell", bundle: .module)
        tableView.register(movementsNibName, forCellReuseIdentifier: timelineMovementCellIdentifier)
        tableView.register(reducedNibName, forCellReuseIdentifier: timelineReducedDebtCellIdentifier)
    }
    
    func didUpdateDataSourceWith(_ model: TimeLineViewModel) {
        timeLineViewModel = model
    }
    
    func getItemSourceAtIndexPath(_ indexPath: IndexPath) -> ExpenseType {
        return itemsSource[indexPath.section][indexPath.row].expenseType
    }
    
    func clearData() {
        timeLineViewModel = nil
        activeMonth = nil
        items = nil
    }
}

extension TimeLineDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemsSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  itemsSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let item = itemsSource[indexPath.section][indexPath.row]
        if item.expenseType == .reducedDebt {
            if let optCell = tableView.dequeueReusableCell(withIdentifier: timelineReducedDebtCellIdentifier, for: indexPath) as? ReducedDebtCell {
                optCell.configurewithModel(item)
                cell = optCell
            }
        } else {
            if let optCell = tableView.dequeueReusableCell(withIdentifier: timelineMovementCellIdentifier, for: indexPath) as? TimeLineMovementCell {
                optCell.configurewithModel(item)
                let bottomLineBeVisibility = isLastCellInSectionForIndexPath(indexPath, inTableView: tableView)
                optCell.hideBottomLine(bottomLineBeVisibility)
                cell = optCell
            }
        }
        
        return cell ?? TimeLineMovementCell()
    }
}

private extension TimeLineDataSource {
    func isLastCellInSectionForIndexPath(_ indexPath: IndexPath, inTableView tableView: UITableView) -> Bool {
        let itemsInSection = itemsSource[indexPath.section]
        return (itemsInSection.count-1) == indexPath.row
    }
}
