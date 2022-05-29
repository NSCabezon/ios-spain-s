//

import Foundation

class ConfirmationBuilder {
    
    private let dependencies: PresentationComponent
    private var items: [ConfirmationBuilderItem] = []
    
    private struct ConfirmationBuilderItem: Equatable {
        let titleKey: String
        let value: String?
        let valueLines: Int
        func hash(into hasher: inout Hasher) {
            hasher.combine(titleKey)
        }
    }
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    func add(_ titleKey: String, string: String?, valueLines: Int = 1) {
        items.append(ConfirmationBuilderItem(titleKey: titleKey, value: string, valueLines: valueLines))
    }
    
    func add(_ titleKey: String, amount: Amount?, valueLines: Int = 1) {
        items.append(ConfirmationBuilderItem(titleKey: titleKey, value: amount?.getAbsFormattedAmountUI(), valueLines: valueLines))
    }
    
    func addExchangeType(_ titleKey: String, data: NoSepaTransferOperativeData, decimals: Int = 4, valueLines: Int = 1) {
        guard var amount = data.noSepaTransferValidation?.preciseAmountNumber.getFormattedAmountUI(currencyFormat: .none, decimals),
              let currencyPayer = data.noSepaTransferValidation?.settlementAmountPayer?.currencyName, !currencyPayer.isEmpty,
              let currencyBenef = data.noSepaTransferValidation?.settlementAmountBenef?.currencyName, !currencyBenef.isEmpty
        else { return }
        amount += " \(currencyPayer)/\(currencyBenef)"
        items.append(ConfirmationBuilderItem(titleKey: titleKey, value: amount, valueLines: valueLines))
    }
    
    func add(_ titleKey: String, date: Date?, format: TimeFormat, valueLines: Int = 1) {
        items.append(ConfirmationBuilderItem(titleKey: titleKey, value: dependencies.timeManager.toString(date: date, outputFormat: format), valueLines: valueLines))
    }
    
    func build(withFirstElement isFirstElement: Bool = false) -> [ConfirmationTableViewItemModel] {
        return items.map {
            if $0 == items.first && isFirstElement {
                return ConfirmationTableViewItemModel(dependencies.stringLoader.getString($0.titleKey), $0.value ?? "", false, dependencies, isFirst: true, valueLines: $0.valueLines)
            } else if $0 == items.last {
                return ConfirmationTableViewItemModel(dependencies.stringLoader.getString($0.titleKey), $0.value ?? "", true, dependencies, valueLines: $0.valueLines)
            } else {
                return ConfirmationTableViewItemModel(dependencies.stringLoader.getString($0.titleKey), $0.value ?? "", false, dependencies, valueLines: $0.valueLines)
            }
        }
    }
}
