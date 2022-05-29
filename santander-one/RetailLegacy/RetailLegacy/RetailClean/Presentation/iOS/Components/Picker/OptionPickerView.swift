import UIKit

protocol OptionPickerDelegate: class {
    func optionPicker(_ optionPicker: OptionPickerView, didSelectOption position: Int?)
}

protocol OptionPickerDatasource: class {
    func numberOfRows(in optionPicker: OptionPickerView) -> Int
    func optionPicker(_ optionPicker: OptionPickerView, titleFor row: Int) -> String
}

class OptionPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var delegate: OptionPickerDelegate?
    weak var dataSource: OptionPickerDatasource?
    lazy private var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private var closeTitle: String?
    
    init(frame: CGRect, closeTitle: String) {
        super.init(frame: frame)
        backgroundColor = .uiWhite
        self.closeTitle = closeTitle
        setupPicker()
    }
    
    convenience init(closeTitle: String) {
        self.init(frame: .zero, closeTitle: closeTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .uiWhite
        setupPicker()
    }
    
    private func setupPicker() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(pickerView)
        pickerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        pickerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barStyle = .default
        toolBar.isTranslucent = false
        toolBar.backgroundColor = .sanRed
        toolBar.barTintColor = .sanRed
        toolBar.tintColor = .uiWhite
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: closeTitle, style: .done, target: self, action: #selector(donePressed))
        toolBar.setItems([space, doneButton], animated: false)
        addSubview(toolBar)
        toolBar.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        toolBar.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: pickerView.topAnchor).isActive = true
    }
    
    @objc func donePressed() {
        delegate?.optionPicker(self, didSelectOption: pickerView.selectedRow(inComponent: 0))
    }
    
    // MARK: - UIPickerViewDatasource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource?.numberOfRows(in: self) ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource?.optionPicker(self, titleFor: row)
    }

}
