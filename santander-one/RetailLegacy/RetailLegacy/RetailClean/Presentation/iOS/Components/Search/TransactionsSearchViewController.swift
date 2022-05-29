import UIKit

protocol SearchDateParameters: DatePickerControllerConfiguration {
    var textField: UITextField { get }
    var configuration: DatePickerControllerConfiguration { get }
}

protocol SearchInputProvider: class {
    func requestDate(currentDate: Date?, minimumDate: Date?, maximumDate: Date?, completion: @escaping (Date?) -> Void)
    func requestOptions(_ options: [String], selectedOption: Int?, completion: @escaping (Int?) -> Void)
}

class TransactionsSearchViewController: BaseViewController<TransactionsSearchPresenterProtocol> {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var bottomButtonContainer: UIView!
    @IBOutlet weak var bottomButton: RedButton!
    private var dateRequestCompletion: ((Date?) -> Void)?
    private var optionRequestCompletion: ((Int?) -> Void)?
    weak private var pickerContainer: UIView?
    weak private var datePicker: UIDatePicker?
    weak private var optionPicker: UIPickerView?
    private var pickerOptionHandler: PickerOptionHandler?
    @IBOutlet weak var heightBottomButton: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    private var dataSource: TableDataSource = {
        return TableDataSource()
    }()
    
    override class var storyboardName: String {
        return "TransactionsSearch"
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .uiBackground
        tableView.separatorStyle = .none
        tableView.backgroundColor = .uiBackground
        tableView.registerCells(["SearchParameterDateTableViewCell", "SearchParameterDateRangeUITableViewCell", "SearchParameterStringTableViewCell", "SearchParameterFakePickerTableViewCell", "SearchParameterAmountRangeTableViewCell", "SearchParameterSegementedOptionTableViewCell", "SearchParameterSearchButtonTableViewCell"])
        tableView.dataSource = dataSource
        dataSource.addSections(presenter.parameters)
        
        bottomButtonContainer.backgroundColor = .uiBackground
        bottomButton.setTitle(presenter.searchDescription, for: .normal)
        (bottomButton as UIButton).applyStyle(ButtonStylist(textColor: .uiWhite, font: UIFont.latoMedium(size: 16.0)))
        bottomButtonContainer.isHidden = presenter.shouldHideDefaultSearchButton
        bottomButton.isHidden = presenter.shouldHideDefaultSearchButton
        heightBottomButton.constant = presenter.shouldHideDefaultSearchButton ? 0 : bottomButtonContainer.bounds.height
        
        if presenter.shouldHideDefaultSearchButton {
            tableViewBottomConstraint.isActive = false
            let constraint = NSLayoutConstraint(item: tableView as UITableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            constraint.isActive = true
        }
        
        if let headerView = presenter.searchHeader.instantiateFromNib() as? BaseHeader {            
            headerContainer.addSubview(headerView)
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.topAnchor.constraint(equalTo: headerContainer.topAnchor).isActive = true
            headerView.leftAnchor.constraint(equalTo: headerContainer.leftAnchor).isActive = true
            headerView.rightAnchor.constraint(equalTo: headerContainer.rightAnchor).isActive = true
            headerView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor).isActive = true
            
            let viewModel = presenter.searchHeaderViewModel
            viewModel.configure(headerView)
        }
    }
        
    @objc func dateSelected() {
        let conditions = (current: datePicker?.date, minimum: datePicker?.minimumDate, maximum: datePicker?.maximumDate)
        let validDate: Date?
        switch conditions {
        case let (current?, minimum?, _) where current < minimum:
            validDate = minimum
        case let (current?, _, maximum?) where current > maximum:
            validDate = maximum
        case let (current, _, _):
            validDate = current
        }
        dateRequestCompletion?(validDate)
        removePicker()
    }
    
    @objc func optionSelected() {
        optionRequestCompletion?(optionPicker?.selectedRow(inComponent: 0))
        removePicker()
    }
    
    @objc func cancelDate() {
        dateRequestCompletion?(nil)
        removePicker()
    }
    
    @objc func cancelOption() {
        optionRequestCompletion?(nil)
        removePicker()
    }
    
    @IBAction func onBottomButtonClick(_ sender: Any) {
        presenter.searchButtonWasTapped(text: nil, criteria: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent == true {
            presenter.cancelChanges()
        }
    }
    
    override func showMenu() {
        presenter.toggleSideMenu()
    }
}

extension TransactionsSearchViewController: SearchInputProvider {
    
    func requestOptions(_ options: [String], selectedOption: Int?, completion: @escaping (Int?) -> Void) {
        if self.pickerContainer != nil {
            removePicker()
            self.dateRequestCompletion?(nil)
            self.optionRequestCompletion?(nil)
        }
        self.view.endEditing(true)
        optionRequestCompletion = completion
        
        let (pickerContainer, toolBar) = createPickerContainer(isOption: true)
        
        let pickerHandler = PickerOptionHandler(with: options)
        pickerOptionHandler = pickerHandler
        let optionsPicker = UIPickerView()
        self.optionPicker = optionsPicker
        optionsPicker.delegate = pickerHandler
        optionsPicker.dataSource = pickerHandler
        if let selectedOption = selectedOption {
            optionsPicker.selectRow(selectedOption, inComponent: 0, animated: true)
        }
        optionsPicker.translatesAutoresizingMaskIntoConstraints = false
        pickerContainer.addSubview(optionsPicker)
        setupConstraints(optionsPicker, pickerContainer, toolBar)
        optionsPicker.reloadAllComponents()
    }
    
    func removePicker() {
        pickerContainer?.removeFromSuperview()
    }
    
    func requestDate(currentDate: Date?, minimumDate: Date?, maximumDate: Date?, completion: @escaping (Date?) -> Void) {
        
        if self.pickerContainer != nil {
            removePicker()
            self.dateRequestCompletion?(nil)
            self.optionRequestCompletion?(nil)
        }
        self.view.endEditing(true)
        dateRequestCompletion = completion
        
        let (pickerContainer, toolBar) = createPickerContainer(isOption: false)
        
        let datePicker = UIDatePicker()
        self.datePicker = datePicker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.locale = NSLocale.current
        datePicker.timeZone = TimeZone(abbreviation: "GMT")
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        if let currentDate = currentDate {
            datePicker.setDate(currentDate, animated: false)
        }
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        pickerContainer.addSubview(datePicker)
        setupConstraints(datePicker, pickerContainer, toolBar)
    }
 
    private func createPickerContainer(isOption: Bool) -> (UIView, UIToolbar) {
        let pickerContainer = UIView()
        self.pickerContainer = pickerContainer
        pickerContainer.backgroundColor = .uiWhite
        pickerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerContainer)
        let toolBar = UIToolbar()
        toolBar.tintColor = .uiWhite
        toolBar.barTintColor = .sanRed
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.isTranslucent = true
        pickerContainer.addSubview(toolBar)
        let doneText = stringLoader.getString("generic_button_accept").text.camelCasedString
        let cancelText = stringLoader.getString("generic_button_cancel").text.camelCasedString

        let doneButton: UIBarButtonItem
        let cancelButton: UIBarButtonItem
        if isOption {
            doneButton = UIBarButtonItem(title: doneText, style: .done, target: self, action: #selector(optionSelected))
            cancelButton = UIBarButtonItem(title: cancelText, style: .done, target: self, action: #selector(cancelOption))
        } else {
            doneButton = UIBarButtonItem(title: doneText, style: .done, target: self, action: #selector(dateSelected))
            cancelButton = UIBarButtonItem(title: cancelText, style: .done, target: self, action: #selector(cancelDate))
        }
        doneButton.setTitleTextAttributes([.font: UIFont.latoBold(size: 16)], for: .normal)
        doneButton.setTitleTextAttributes([.font: UIFont.latoBold(size: 16), .foregroundColor: UIColor.uiWhite], for: .highlighted)
        cancelButton.setTitleTextAttributes([.font: UIFont.latoBold(size: 16)], for: .normal)
        cancelButton.setTitleTextAttributes([.font: UIFont.latoBold(size: 16), .foregroundColor: UIColor.uiWhite], for: .highlighted)
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, space, doneButton], animated: false)
        return (pickerContainer, toolBar)
    }
    
    private func setupConstraints(_ datePicker: UIView, _ pickerContainer: UIView, _ toolBar: UIToolbar) {
        datePicker.bottomAnchor.constraint(equalTo: pickerContainer.bottomAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: pickerContainer.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: pickerContainer.trailingAnchor).isActive = true
        datePicker.topAnchor.constraint(equalTo: toolBar.bottomAnchor).isActive = true
        toolBar.leadingAnchor.constraint(equalTo: pickerContainer.leadingAnchor).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: pickerContainer.trailingAnchor).isActive = true
        pickerContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pickerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pickerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pickerContainer.topAnchor.constraint(equalTo: toolBar.topAnchor).isActive = true
    }
}

class PickerOptionHandler: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var options: [String]
    
    init(with options: [String]) {
        self.options = options
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

// MARK: - Enable side menu
extension TransactionsSearchViewController: RootMenuController {
    
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
    
}
