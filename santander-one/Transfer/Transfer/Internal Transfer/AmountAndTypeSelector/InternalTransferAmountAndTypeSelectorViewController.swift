import UIKit
import UI
import Operative
import CoreFoundationLib

protocol InternalTransferAmountAndTypeSelectorViewProtocol: OperativeView {
    var type: InternalTransferDateTypeViewModel { get }
    var amount: String? { get }
    var concept: String? { get }
    var oneDayDate: Date? { get }
    var periodicEmissionDate: InternalTransferEmissionTypeViewModel? { get }
    var periodicStartDate: Date? { get }
    var periodicEndDate: Date? { get }
    var periodicPeriodicity: InternalTransferPeriodicityTypeViewModel? { get }
    var periodicEndDateNever: Bool { get }
    func set(accountViewModel: SelectedAccountHeaderViewModel, amount: String?, concept: String?, type: InternalTransferDateTypeFilledViewModel)
    func showFaqs(_ items: [FaqsItemViewModel])
    func updateContinueAction(_ enable: Bool)
    func showInvalidAmount(_ error: String)
    func clearInvalidAmount()
    func setupPeriodicityModel(with model: [InternalTransferPeriodicityTypeViewModel])
    func setSelectorBussinnessDayVisibility(isEnabled: Bool)
}

final class InternalTransferAmountAndTypeSelectorViewController: UIViewController {
    private let dependenciesEngine: DependenciesDefault
    var type: InternalTransferDateTypeViewModel = .now
    var maxLenghtConcept: Int {
        return self.dependenciesEngine.resolve(for: LocalAppConfig.self).maxLengthInternalTransferConcept
    }
    @IBOutlet private weak var originAccountView: SelectedAccountHeaderView!
    
    @IBOutlet weak var amountErrorView: UIView! {
        didSet {
            self.amountErrorView.isHidden = true
        }
    }
    @IBOutlet weak var amountErrorLabel: UILabel! {
        didSet {
            self.amountErrorLabel.setSantanderTextFont(type: .regular, size: 13, color: .bostonRed)
        }
    }

    @IBOutlet private var amountTextfield: LisboaTextfield! {
        didSet {
            self.presenter.fields.append(amountTextfield)
            self.amountTextfield.updatableDelegate = self
            self.amountTextfield.titleLabel.accessibilityIdentifier = AccessibilityTransfers.inputAmountTitle.rawValue
            self.amountTextfield.field.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputAmount.rawValue
            self.amountTextfield.writteButton.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputAmount.rawValue + "button"
            self.amountTextfield.field.isAccessibilityElement = true
            self.amountTextfield.setAccesibilityExtraInfo(accessibilityLabel: self.amount?.amountAndCurrency() ?? "")
        }
    }
    
    @IBOutlet private var conceptTextField: LisboaTextfield! {
        didSet {
            self.conceptTextField.titleLabel.accessibilityIdentifier = AccessibilityTransfers.inputConceptTitle.rawValue
            self.conceptTextField.field.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputConcept.rawValue
            self.conceptTextField.writteButton.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputConcept.rawValue + "button"
            self.conceptTextField.field.isAccessibilityElement = true
        }
    }
    @IBOutlet private var whenDescriptionLabel: UILabel! {
        didSet {
            self.whenDescriptionLabel.accessibilityIdentifier = AccessibilityInternalTransferAmount.labelWhenDescriptionTitle.rawValue
            
        }
    }
    @IBOutlet private var whenSegmentView: UIView!
    @IBOutlet private var whenSegmentControl: LisboaSegmentedControl!
    @IBOutlet private var oneDayDateField: LisboaTextfield! {
        didSet {
            self.oneDayDateField.titleLabel.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputScheduledDate.rawValue + "title"
            self.oneDayDateField.field.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputScheduledDate.rawValue
            self.oneDayDateField.writteButton.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputScheduledDate.rawValue + "button"
        }
    }
    @IBOutlet private var oneDayView: UIView!
    @IBOutlet private var periodicViews: [UIView]!
    private let periodicPeriodicityField = TextFieldSelectorView<InternalTransferPeriodicityTypeViewModel>()
    @IBOutlet private var periodicityViewContainer: UIStackView!
    @IBOutlet private var periodicStartDateField: LisboaTextfield! {
        didSet {
            self.periodicStartDateField.titleLabel.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputStartDate.rawValue + "title"
            self.periodicStartDateField.field.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputStartDate.rawValue
            self.periodicStartDateField.writteButton.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputStartDate.rawValue + "button"
        }
    }
    @IBOutlet private var periodicEndDateField: LisboaTextfield! {
        didSet {
            self.periodicEndDateField.titleLabel.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputEndDate.rawValue + "title"
            self.periodicEndDateField.field.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputEndDate.rawValue
            self.periodicEndDateField.writteButton.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputEndDate.rawValue + "button"
        }
    }
    @IBOutlet private var periodicEmissionDateField: LisboaTextfield! {
        didSet {
            self.periodicEmissionDateField.titleLabel.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputEmissionDate.rawValue + "title"
            self.periodicEmissionDateField.field.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputEmissionDate.rawValue
            self.periodicEmissionDateField.writteButton.accessibilityIdentifier = AccessibilityInternalTransferAmount.inputEmissionDate.rawValue + "button"
        }
    }
    @IBOutlet private var separator: UIView!
    @IBOutlet private var continueButton: WhiteLisboaButton! {
        didSet {
            self.continueButton.accessibilityIdentifier = AccessibilityInternalTransferAmount.btnContinue.rawValue
        }
    }
    @IBOutlet private var scrollview: UIScrollView!
    @IBOutlet private var footerView: UIView!
    @IBOutlet private var periodicEndDateNeverButton: UIButton! {
        didSet {
            self.periodicEndDateNeverButton.accessibilityIdentifier = AccessibilityInternalTransferAmount.btnEndDateNever.rawValue
        }
    }
    @IBOutlet private var periodicEndDateNeverLabel: UILabel! {
        didSet {
            periodicEndDateNeverLabel.accessibilityIdentifier = AccessibilityInternalTransferAmount.labelEndDateNever.rawValue
        }
    }
    @IBOutlet private var bottomSpaceConstraint: NSLayoutConstraint!
    private let presenter: InternalTransferAmountAndTypeSelectorPresenterProtocol
    private var sectionResponder: EditSectionResponder? {
        if amountTextfield.isFirstResponder {
            return .amount
        } else  if conceptTextField.isFirstResponder {
            return .concept
        } else if oneDayDateField.isFirstResponder {
            return .oneDayDate
        } else if periodicStartDateField.isFirstResponder {
            return .periodicStartDate
        } else if periodicEndDateField.isFirstResponder {
            return .periodicEndDate
        } else if periodicEmissionDateField.isFirstResponder {
            return .periodicEmissionDate
        } else {
            return nil
        }
    }
    private var fieldSectionRespnder: LisboaTextfield? {
        switch sectionResponder {
        case .amount?:
            return amountTextfield
        case .concept?:
            return conceptTextField
        case .oneDayDate?:
            return oneDayDateField
        case .periodicStartDate?:
            return periodicStartDateField
        case .periodicEndDate?:
            return periodicEndDateField
        case .periodicEmissionDate?:
            return periodicEmissionDateField
        case .none:
            return nil
        }
    }
    let keyboardManager = KeyboardManager()
    private var selectedPeriodicity: InternalTransferPeriodicityTypeViewModel?
    private var periodicityTypes: [InternalTransferPeriodicityTypeViewModel] = []
    
    // MARK: - Class Methods

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: InternalTransferAmountAndTypeSelectorPresenterProtocol,
         dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        setupView()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
        self.continueButton.addSelectorAction(target: self, #selector(continueAction))
        self.keyboardManager.setDelegate(self)
        self.presenter.loaded()
        self.setupNavigationBar()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }

    // MARK: - Actions Methods
    
    @IBAction func changeNeverEndDate() {
        self.hideKeyboard()
        self.periodicEndDateNeverButton.isSelected = !self.periodicEndDateNeverButton.isSelected
        if self.periodicEndDateNeverButton.isSelected {
            periodicEndDateField.updateData(text: nil)
        } else if let startDate = self.periodicStartDate {
            let dateEnd = startDate.getDateByAdding(days: 1)
            createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
            periodicEndDateField.updateData(text: convertDateToString(from: dateEnd))
        }
    }

    @IBAction func changeWhenSegment() {
        self.hideKeyboard()
        switch whenSegmentControl.selectedSegmentIndex {
        case 0:
            updateWithType(type: .now)
        case 1:
            updateWithType(type: .day)
        case 2:
            updateWithType(type: .periodic)
        default:
            break
        }
        DispatchQueue.main.async(execute: self.keyboardManager.update)
    }
    
    @IBAction func continueAction() {
        self.view.endEditing(false)
        self.presenter.continueSelected()
    }
    
    private func continueActionTextfield(_ textfield: EditText) {
        self.continueAction()
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard notification.userInfo != nil else {
            return
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard notification.userInfo != nil else {
            return
        }
    }
    
    @objc func pickerDidChange() {
        switch sectionResponder {
        case .amount, .concept, .none:
            break
        case .oneDayDate:
            oneDayDateUpdateData()
        case .periodicStartDate:
            periodicStartDateUpdateData()
        case .periodicEndDate:
            periodicEndDateUpdateData()
        case .periodicEmissionDate:
            periodicEmissionDateUpdateData()
        }
    }
    
    @objc func cancelPicker() {
        self.view.endEditing(true)
    }
}

extension InternalTransferAmountAndTypeSelectorViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

// MARK: - Private Methods

private extension InternalTransferAmountAndTypeSelectorViewController {
    func convertDateToString(from date: Date) -> String? {
        return dateToString(date: date, outputFormat: TimeFormat.dd_MMM_yyyy)?.capitalized
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "toolbar_title_amount",
                                    header: .title(key: "toolbar_title_transfer", style: .default))
        )
        builder.setRightActions(
        NavigationBarBuilder.RightAction.close(action: #selector(close)),
        NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: nil)
    }
    
    @IBAction func faqs() {
        self.presenter.faqs()
    }
    
    @IBAction func close() {
        self.presenter.close()
    }
    
    func updateWithType(type: InternalTransferDateTypeViewModel) {
        if self.type != type {
            self.type = type
            self.updateTypeState()
        }
    }
    
    func updateTypeState() {
        let index: Int
        switch type {
        case .now:
            index = 0
            hiddeOneDay()
            hiddePeridic()
        case .day:
            index = 1
            showOneDay()
            hiddePeridic()
        case .periodic:
            index = 2
            hiddeOneDay()
            showPeriodic()
        }
        self.whenSegmentControl.selectedSegmentIndex = index
    }
    
    func showOneDay() {
        oneDayView.isHidden = false
    }
    
    func hiddeOneDay() {
        oneDayView.isHidden = true
        let date = Date().getDateByAdding(days: self.presenter.differenceOfDaysToDeferredTransfers())
        oneDayDateField.updateData(text: convertDateToString(from: date))
        createDatePicker(for: oneDayDateField, date: date, minimumDate: date)
    }
    
    func showPeriodic() {
        periodicViews.forEach { $0.isHidden = false }
    }
    
    func hiddePeridic() {
        periodicViews.forEach { $0.isHidden = true }
        self.periodicEndDateField.updateData(text: nil)
        self.periodicEndDateNeverButton.isSelected = true
        if let defaultPeriodicity = self.periodicityTypes.first {
            self.periodicPeriodicityField.selectElement(defaultPeriodicity)
            self.selectedPeriodicity = defaultPeriodicity
        }
        periodicEmissionDateField.updateData(text: localized(InternalTransferEmissionTypeViewModel.previous.text))
        createPicker(for: periodicEmissionDateField, index: nil)
        let dateStart = Date().getDateByAdding(days: self.presenter.differenceOfDaysToDeferredTransfers())
        let dateEnd = Date().getDateByAdding(days: self.presenter.differenceOfDaysToDeferredTransfers() + 1)
        periodicStartDateField.updateData(text: convertDateToString(from: dateStart))
        createDatePicker(for: periodicStartDateField, date: dateStart, minimumDate: dateStart)
        createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
    }
    
    func setupView() {
        self.view.backgroundColor = UIColor.white
        self.periodicEndDateNeverButton.setImage(Assets.image(named: "checkboxSelected"), for: UIControl.State.selected)
        self.periodicEndDateNeverButton.setImage(Assets.image(named: "checkboxDefault"), for: UIControl.State.normal)
        self.periodicEndDateNeverLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.periodicEndDateNeverLabel.textColor = UIColor.lisboaGray
        self.periodicEndDateNeverLabel.text = localized("sendMoney_label_indefinite")
        self.originAccountView.backgroundColor = UIColor.skyGray
        self.whenDescriptionLabel.textColor = UIColor.lisboaGray
        self.whenDescriptionLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.whenDescriptionLabel.text = localized("transfer_label_periodicity")
        self.whenSegmentView.backgroundColor = UIColor.skyGray
        self.whenSegmentView.layer.borderColor = UIColor.skyGray.cgColor
        self.whenSegmentView.layer.borderWidth = 1
        self.whenSegmentView.layer.cornerRadius = 5
        self.whenSegmentView.clipsToBounds = true
        self.whenSegmentControl.setup(with: [localized("sendMoney_tab_now"),
                                             localized("sendMoney_tab_chooseDay"),
                                             localized("sendMoney_tab_periodic")],
                                      accessibilityIdentifiers: ["sendMoney_tab_now",
                                                                 "sendMoney_tab_chooseDay",
                                                                 "sendMoney_tab_periodic"],
                                      withStyle: .defaultSegmentedControlStyle)
        self.separator.backgroundColor = UIColor.mediumSkyGray
        self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        let icnCurrency = NumberFormattingHandler.shared.getDefaultCurrencyTextFieldIcn()
        self.amountTextfield.configure(with: UIAmountTextFieldFormatter(), title: localized("newSendOnePay_label_amount"), extraInfo: (image: Assets.image(named: icnCurrency), action: { [weak self] in
            self?.amountTextfield.field.becomeFirstResponder()
        }))
        self.amountTextfield.field.keyboardType = .decimalPad
        let conceptFormmater = UIFormattedCustomTextField()
        conceptFormmater.setMaxLength(maxLength: self.maxLenghtConcept)
        self.conceptTextField.setAllowOnlyCharacters(.operative)
        self.conceptTextField.configure(with: conceptFormmater, title: localized("transfer_label_concept"), extraInfo: nil)
        self.oneDayDateField.configure(with: nil, title: localized("sendMoney_label_issuanceDate"), extraInfo: (image: Assets.image(named: "btnCalendar"), action: { [weak self] in
            self?.oneDayDateField.field.becomeFirstResponder()
        }), disabledActions: TextFieldActions.usuallyDisabledActions)
        self.periodicStartDateField.configure(with: nil, title: localized("sendMoney_label_startDate"), extraInfo: (image: Assets.image(named: "btnCalendar"), action: { [weak self] in
            self?.periodicStartDateField.field.becomeFirstResponder()
        }), disabledActions: TextFieldActions.usuallyDisabledActions)
        self.periodicEndDateField.configure(with: nil, title: localized("sendMoney_label_endDate"), extraInfo: (image: Assets.image(named: "btnCalendar"), action: { [weak self] in
            self?.periodicEndDateField.field.becomeFirstResponder()
        }), disabledActions: TextFieldActions.usuallyDisabledActions)
        self.periodicEmissionDateField.configure(with: nil, title: localized("sendMoney_label_workingDayIssue"), extraInfo: (image: Assets.image(named: "icnArrowDownGreen"), action: { [weak self] in
            self?.periodicEmissionDateField.field.becomeFirstResponder()
        }), disabledActions: TextFieldActions.usuallyDisabledActions)
        createPicker(for: periodicEmissionDateField, index: nil)
        createDatePicker(for: oneDayDateField, date: Date(), minimumDate: Date())
        createDatePicker(for: periodicStartDateField, date: Date(), minimumDate: Date())
        createDatePicker(for: periodicEndDateField, date: Date(), minimumDate: Date())
        self.periodicityViewContainer.addArrangedSubview(self.periodicPeriodicityField)
        self.periodicPeriodicityField.setDropdownAccessibilityIdentifier(AccessibilityInternalTransferAmount.inputPeriodicity.rawValue)
        updateTypeState()
    }
    
    func createPicker(for field: LisboaTextfield, index: Int?) {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.showsSelectionIndicator = true
        picker.selectRow(index ?? 0, inComponent: 0, animated: false)
        field.field.inputView = picker
    }
    
    func createDatePicker(for field: LisboaTextfield, date: Date, minimumDate: Date) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.date = date
        datePicker.locale = NSLocale.current
        datePicker.timeZone = TimeZone(abbreviation: "GMT")
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = nil
        datePicker.addTarget(self, action: #selector(pickerDidChange), for: .valueChanged)
        field.field.inputView = datePicker
    }
    
    func oneDayDateUpdateData() {
        if let datePicker = oneDayDateField?.field.inputView as? UIDatePicker {
            let date = datePicker.date
            oneDayDateField.updateData(text: convertDateToString(from: date))
        }
    }
    
    func periodicStartDateUpdateData() {
        guard let datePicker = periodicStartDateField?.field.inputView as? UIDatePicker else { return }
        let date = datePicker.date
        let dateEnd = date.getDateByAdding(days: 1)
        if !self.periodicEndDateNeverButton.isSelected, let periodicEndDate = self.periodicEndDate {
            if periodicEndDate.compare(date) != .orderedDescending {
                createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
                periodicEndDateField.updateData(text: convertDateToString(from: dateEnd))
            }
        } else {
            createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
        }
        periodicStartDateField.updateData(text: convertDateToString(from: date))
    }
    
    func periodicEndDateUpdateData() {
        guard let datePicker = periodicStartDateField?.field.inputView as? UIDatePicker else { return }
        let date = datePicker.date
        periodicEndDateField.updateData(text: convertDateToString(from: date))
        self.periodicEndDateNeverButton.isSelected = false
    }
    
    func periodicEmissionDateUpdateData() {
        if let picker = fieldSectionRespnder?.field.inputView as? UIPickerView,
           let emission = InternalTransferEmissionTypeViewModel(rawValue: picker.selectedRow(inComponent: 0)) {
            periodicEmissionDateField.updateData(text: localized(emission.text))
        }
    }
}

// MARK: - UIPickerView

extension InternalTransferAmountAndTypeSelectorViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch sectionResponder {
        case .amount?, .concept?, .oneDayDate?, .periodicStartDate?, .periodicEndDate?, .none:
            return nil
        case .periodicEmissionDate:
            return InternalTransferEmissionTypeViewModel.allCases[row].text
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerDidChange()
    }
}

extension InternalTransferAmountAndTypeSelectorViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch sectionResponder {
        case .amount?, .concept?, .oneDayDate?, .periodicStartDate?, .periodicEndDate?, .none:
            return 0
        case .periodicEmissionDate:
            return InternalTransferEmissionTypeViewModel.allCases.count
        }
    }
}

// MARK: - InternalTransferAmountAndTypeSelectorViewProtocol

extension InternalTransferAmountAndTypeSelectorViewController: InternalTransferAmountAndTypeSelectorViewProtocol {
    var periodicPeriodicity: InternalTransferPeriodicityTypeViewModel? {
        return self.selectedPeriodicity
    }
    var periodicEmissionDate: InternalTransferEmissionTypeViewModel? {
        return InternalTransferEmissionTypeViewModel(rawValue: (periodicEmissionDateField.field.inputView as? UIPickerView)?.selectedRow(inComponent: 0) ?? 0)
    }
    var oneDayDate: Date? {
        return (oneDayDateField.field.inputView as? UIDatePicker)?.date
    }
    var periodicStartDate: Date? {
        return (periodicStartDateField.field.inputView as? UIDatePicker)?.date
    }
    var periodicEndDate: Date? {
        return (periodicEndDateField.field.inputView as? UIDatePicker)?.date
    }
    var operativePresenter: OperativeStepPresenterProtocol {
        return presenter
    }
    var amount: String? {
        return amountTextfield.text
    }
    var concept: String? {
        return conceptTextField.text
    }
    var periodicEndDateNever: Bool {
        return self.periodicEndDateNeverButton.isSelected
    }

    func set(accountViewModel: SelectedAccountHeaderViewModel, amount: String?, concept: String?, type: InternalTransferDateTypeFilledViewModel) {
        updateTypeState()
        amountTextfield.updateData(text: amount)
        conceptTextField.updateData(text: concept)
        self.originAccountView.setup(with: accountViewModel)
        
        switch type {
        case .now:
            updateWithType(type: .now)
        case .day(let date):
            oneDayDateField.updateData(text: convertDateToString(from: date))
            updateWithType(type: .day)
        case .periodic(let start, let end, _, let emission):
            periodicStartDateField.updateData(text: convertDateToString(from: start))
            switch end {
            case .never:
                periodicEndDateField.updateData(text: nil)
                self.periodicEndDateNeverButton.isSelected = true
            case .date(let date):
                periodicEndDateField.updateData(text: convertDateToString(from: date))
                self.periodicEndDateNeverButton.isSelected = false
            }
            periodicEmissionDateField.updateData(text: localized(emission.text))
            createPicker(for: periodicEmissionDateField, index: emission.rawValue)
            updateWithType(type: .periodic)
        }
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }

    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }

    func showInvalidAmount(_ error: String) {
        self.amountTextfield.setErrorAppearance()
        self.amountErrorView.isHidden = false
        self.amountErrorLabel.text = error
    }

    func clearInvalidAmount() {
        guard !amountErrorView.isHidden else { return }
        self.amountErrorView.isHidden = true
        self.amountTextfield.clearErrorAppearanceWithFieldVisible()
    }
    
    func setupPeriodicityModel(with model: [InternalTransferPeriodicityTypeViewModel]) {
        self.periodicityTypes = model
        self.periodicPeriodicityField.configureWithProducts(model, title: "") { [weak self] periodicity in
            self?.selectedPeriodicity = periodicity
        }
        if let defaultPeriodicity = model.first {
            self.periodicPeriodicityField.selectElement(defaultPeriodicity)
            self.selectedPeriodicity = defaultPeriodicity
        }
    }
    
    func setSelectorBussinnessDayVisibility(isEnabled: Bool) {
        self.periodicEmissionDateField.isHidden = !isEnabled
    }
}

extension InternalTransferAmountAndTypeSelectorViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}

extension InternalTransferAmountAndTypeSelectorViewController: UpdatableTextFieldDelegate {
    @objc func updatableTextFieldDidUpdate() {
        self.presenter.validatableFieldChanged()
        self.clearInvalidAmount()
    }
}

extension InternalTransferAmountAndTypeSelectorViewController: KeyboardManagerDelegate {
    var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("generic_button_continue"), accessibilityIdentifier: AccessibilityInternalTransferAmount.transferAmountAndTypeBtnContinue.rawValue, action: self.continueActionTextfield)
    }
}

// MARK: - ViewModels

private enum EditSectionResponder {
    case amount
    case concept
    case oneDayDate
    case periodicStartDate
    case periodicEndDate
    case periodicEmissionDate
}

enum InternalTransferDateTypeViewModel {
    case now
    case day
    case periodic
}

enum InternalTransferDateTypeFilledViewModel {
    case now
    case day(date: Date)
    case periodic(start: Date, end: InternalTransferPeroidicEndDateTypeFilledViewModel, periodicity: InternalTransferPeriodicityTypeViewModel, emission: InternalTransferEmissionTypeViewModel)
}

enum InternalTransferPeroidicEndDateTypeFilledViewModel {
    case never
    case date(Date)
}

public enum InternalTransferPeriodicityTypeViewModel: Int, CaseIterable {
    case month = 0
    case quarterly = 1
    case semiannual = 2
    case weekly = 3
    case bimonthly = 4
    case annual = 5
    
    var text: String {
        let key: String
        switch self {
        case .month:
            key = "generic_label_monthly"
        case .quarterly:
            key = "generic_label_quarterly"
        case .semiannual:
            key = "generic_label_biannual"
        case .weekly:
            key = "generic_label_weekly"
        case .bimonthly:
            key = "generic_label_bimonthly"
        case .annual:
            key = "generic_label_annual"
        }
        return localized(key)
    }
    
    var transferPeriodicity: TransferPeriodicity {
        switch self {
        case .month:
            return .monthly
        case .quarterly:
            return .quarterly
        case .semiannual:
            return .biannual
        case .weekly:
            return .weekly
        case .bimonthly:
            return .bimonthly
        case .annual:
            return .annual
        }
    }
    
    var internalTransferPeriodicPeriodicityType: ValidateInternalTransferPeriodicPeriodicityType {
        switch self {
        case .month:
            return .month
        case .quarterly:
            return .quarterly
        case .semiannual:
            return .semiannual
        case .weekly:
            return .weekly
        case .bimonthly:
            return .bimonthly
        case .annual:
            return .annual
        }
    }
}

extension InternalTransferPeriodicityTypeViewModel: DropdownElement {
    public var name: String {
        return localized(self.text)
    }
}

enum InternalTransferEmissionTypeViewModel: Int, CaseIterable {
    case previous = 0
    case next = 1
    
    var text: String {
        let key: String
        switch self {
        case .previous:
            key = "sendMoney_label_previousWorkingDay"
        case .next:
            key = "sendMoney_label_laterWorkingDay"
        }
        return localized(key)
    }
    
    var transferWorkingDayIssue: TransferWorkingDayIssue {
        switch self {
        case .next:
            return .laterDay
        case .previous:
            return .previousDay
        }
    }
}
