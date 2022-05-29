import UIKit

protocol DateSelectionViewModel {
    func formatDate(date: Date) -> String
}

protocol DatePickerTableDataSourceDelegate: class {
    func valueChanged(date: Date, indexPath: IndexPath)
}

class DatePickerTableDataSource: TableDataSource {
    weak var pickerDelegate: DatePickerTableDataSourceDelegate?
    private var pickerTextFields: [UITextField: IndexPath] = [:]
    private var pickerControllers: [DatePickerController] = []
    
    func resignDatePickerFirstResponder() {
        let firstResponder = pickerControllers.first { $0.inputView.isFirstResponder }
        firstResponder?.inputView.resignFirstResponder()
    }
    
    func clearDatePickers() {
        pickerTextFields = [:]
        pickerControllers = []
    }
    
    func updateConfig(_ config: DatePickerControllerConfiguration, for datePickerCell: DatePickerCell) {
        pickerControllers.first(where: { $0.inputView == datePickerCell.dateField })?.updateConfiguration(config)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let sectionViewModel = sections[indexPath.section]
        let item = sectionViewModel.get(indexPath.row)
        if let pickerItem = item as? DatePickerControllerConfiguration, let pickerCell = cell as? DatePickerCell {
            newPickerController(for: pickerCell.dateField, withConfiguration: pickerItem, atIndex: indexPath)
        }
        return cell
    }
    
    private func newPickerController(for textField: UITextField, withConfiguration config: DatePickerControllerConfiguration, atIndex indexPath: IndexPath) {
        guard pickerTextFields[textField] == nil else {
            return
        }
        let datePickerController = DatePickerController(configuration: config, inputView: textField, delegate: self)
        pickerControllers += [datePickerController]
        pickerTextFields[textField] = indexPath
    }
}

extension DatePickerTableDataSource: DatePickerControllerDelegate {
    func valueChanged(date: Date, forTextField textField: UITextField) {
        guard let textFieldIndex = pickerTextFields[textField] else {
            return
        }
        let sectionViewModel = sections[textFieldIndex.section]
        let item = sectionViewModel.get(textFieldIndex.row) as? DateSelectionViewModel
        textField.text = item?.formatDate(date: date)
        pickerDelegate?.valueChanged(date: date, indexPath: textFieldIndex)
    }
}
