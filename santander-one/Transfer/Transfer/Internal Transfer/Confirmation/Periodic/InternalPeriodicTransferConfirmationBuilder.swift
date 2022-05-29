import Foundation
import Operative
import CoreFoundationLib

class InternalPeriodicTransferConfirmationBuilder: InternalTransferConfirmationBuilder {
    
    func addPeriodicityInfo(action: ConfirmationItemAction?) {
        guard
            let time = self.internalTransfer.time,
            case .periodic(startDate: _, endDate: _, periodicity: let periodicity, workingDayIssue: _) = time
        else {
            return
        }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_periodicity"),
            value: localized(periodicity.description),
            action: action
        )
        self.items.append(item)
    }
    
    func addStartDate(action: ConfirmationItemAction?) {
        guard
            let time = self.internalTransfer.time,
            case .periodic(startDate: let startDate, endDate: _, periodicity: _, workingDayIssue: _) = time
        else {
            return
        }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_startDate"),
            value: dependenciesResolver.resolve(for: TimeManager.self).toString(date: startDate, outputFormat: .dd_MMMM_YYYY) ?? "",
            action: action
        )
        self.items.append(item)
    }
    
    func addEndDate(action: ConfirmationItemAction?) {
        guard
            let time = self.internalTransfer.time,
            case .periodic(startDate: _, endDate: let endDate, periodicity: _, workingDayIssue: _) = time
        else {
            return
        }
        let value: String
        switch endDate {
        case .never:
            value = localized("confirmation_label_indefinite")
        case .date(let endDate):
            value = dependenciesResolver.resolve(for: TimeManager.self).toString(date: endDate, outputFormat: .dd_MMM_yyyy) ?? ""
        }
        let item = ConfirmationItemViewModel(
            title: localized("confirmation_item_endDate"),
            value: value,
            action: action
        )
        self.items.append(item)
    }
    
}
