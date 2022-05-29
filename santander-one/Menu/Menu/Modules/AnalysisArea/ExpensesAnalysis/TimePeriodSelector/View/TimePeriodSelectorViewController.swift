//
//  TimePeriodSelectorViewController.swift
//  Menu
//
//  Created by Mario Rosales Maillo on 30/6/21.
//

import Foundation
import UI
import CoreFoundationLib

protocol TimePeriodSelectorViewProtocol: AnyObject {
    func setTimeConfiguration(_ configuration: TimePeriodConfiguration)
}

final class TimePeriodSelectorViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timePeriodSelector: HorizontalSelectorView!
    @IBOutlet private var separators: [UIView] = []
    @IBOutlet private weak var saveButton: WhiteLisboaButton!
    @IBOutlet private weak var dateSelectorStack: UIStackView!
    @IBOutlet private weak var fromDateView: SmallLisboaTextField!
    @IBOutlet private weak var toDateView: SmallLisboaTextField!

    private let viewModel: TimePeriodSelectorViewModel
    private let presenter: TimePeriodSelectorPresenterProtocol
    private var items: [HorizontalSelectorItem] = []
    private var selectedType: TimePeriodType?
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    private let dependenciesResolver: DependenciesResolver

    init(presenter: TimePeriodSelectorPresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.viewModel =  TimePeriodSelectorViewModel(resolver: presenter.dependenciesResolver)
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: "TimePeriodSelectorViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedStartDate = Date()
        selectedEndDate = Date()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        setupItems()
        setupUI()
    }
}

extension TimePeriodSelectorViewController: TimePeriodSelectorViewProtocol {
    
    func setTimeConfiguration(_ configuration: TimePeriodConfiguration) {
        self.selectedType = configuration.type
        if let startDate = configuration.startDate {
            self.selectedStartDate = startDate
        }
        if let endDate = configuration.endDate {
            self.selectedEndDate = endDate
        }
        if self.selectedType == .custom {
            self.enabledDateMode()
        }
    }
}

private extension TimePeriodSelectorViewController {
    
    func configureNavigationBar() {
        NavigationBarBuilder(style: .sky,
                             title: .title(key: viewModel.getToolbarTitleKey()))
            .setLeftAction(.back(action: #selector(dismissSelected)))
            .setRightActions(.close(action: #selector(dismissSelected)))
            .build(on: self, with: self.presenter)
    }
    
    func setupUI() {
        saveButton.setTitle(viewModel.getSaveText(), for: .normal)
        saveButton.addAction { [weak self] in
            guard let aSelf = self else { return }
            aSelf.didSaveConfiguration()
        }
        disableSaveButton()
        titleLabel.font = .santander(family: .text, type: .regular, size: 18)
        titleLabel.textColor = .lisboaGray
        titleLabel.configureText(withLocalizedString: viewModel.getChosenTemporalViewText())
        timePeriodSelector.configureWith(items, preSelectedIndex: self.getPreSelectedIndex())
        timePeriodSelector.delegate = self
        separators.forEach { view in view.backgroundColor = .mediumSkyGray }
        setupDates()
        setAccessibilityIdentifiers()
    }
    
    func setupItems() {
        items = [HorizontalSelectorItem(text: viewModel.getPeriodText(for: .monthly), identifier: viewModel.getKey(for: .monthly)),
                 HorizontalSelectorItem(text: viewModel.getPeriodText(for: .quarterly), identifier: viewModel.getKey(for: .quarterly)),
                 HorizontalSelectorItem(text: viewModel.getPeriodText(for: .annual), identifier: viewModel.getKey(for: .annual)),
                 HorizontalSelectorItem(image: Assets.image(named: viewModel.getImageKey(for: .custom)),
                                        selected: Assets.image(named: viewModel.getImageKey(for: .custom, isSelected: true)),
                                        identifier: viewModel.getKey(for: .custom))]
    }
    
    func setupDates() {
        fromDateView.addAction { self.fromDateView.field.becomeFirstResponder() }
        fromDateView.configure(extraInfo: (Assets.image(named: viewModel.getCalendarImageKey()), action: {
            self.fromDateView.field.becomeFirstResponder()
        }))
        fromDateView.updateTitle(viewModel.getDateStart())
        createDatePicker(for: fromDateView, date: selectedStartDate ?? Date(), minimumDate: nil)
        toDateView.addAction { self.toDateView.field.becomeFirstResponder() }
        toDateView.configure(extraInfo: (Assets.image(named: viewModel.getCalendarImageKey()), action: {
            self.toDateView.field.becomeFirstResponder()
        }))
        toDateView.updateTitle(viewModel.getDateEnd())
        createDatePicker(for: toDateView, date: selectedEndDate ?? Date(), minimumDate: Date())
        
        if let startDate = selectedStartDate {
            fromDateView.updateData(text: viewModel.dateFormat(startDate)?.string ?? "")
            fromDateView.field.attributedText = viewModel.dateFormat(startDate)
        }
        if let endDate = selectedEndDate {
            toDateView.updateData(text: viewModel.dateFormat(endDate)?.string ?? "")
            toDateView.field.attributedText = viewModel.dateFormat(endDate)
        }
        if self.selectedType == .custom {
            self.enabledDateMode()
        }
    }
    
    func createDatePicker(for field: SmallLisboaTextField, date: Date, minimumDate: Date?) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.date = date
        datePicker.locale = Locale(identifier: presenter.getLanguage())
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = Date()
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.santanderRed
        toolBar.sizeToFit()
        toolBar.setItems([UIBarButtonItem(title: viewModel.getAcceptText(), style: .done, target: self,
                                          action: #selector(self.donePicker)),
                          UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil,
                                          action: nil),
                          UIBarButtonItem(title: viewModel.getCancelText(), style: .plain, target: self,
                                          action: #selector(self.cancelPicker))], animated: false)
        toolBar.isUserInteractionEnabled = true
        field.field.inputView = datePicker
        field.field.inputAccessoryView = toolBar
    }
    
    @objc func dismissSelected() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func didSaveConfiguration() {
        guard let configType = selectedType else { return }
        let configuration: TimePeriodConfiguration
        switch configType {
        case .custom:
            configuration = TimePeriodConfiguration(.custom, from: selectedStartDate, to: selectedEndDate, dependenciesResolver: dependenciesResolver)
        default:
            configuration = TimePeriodConfiguration(configType, dependenciesResolver: dependenciesResolver)
        }
        self.presenter.didSaveTimePeriodWith(configuration)
    }
    
    @objc func donePicker() {
        let textField: SmallLisboaTextField = toDateView.isFirstResponder ? toDateView : fromDateView
        if let datePicker = textField.field.inputView as? UIDatePicker {
            textField.field.attributedText = viewModel.dateFormat(datePicker.date)
            if fromDateView.isFirstResponder {
                selectedStartDate = datePicker.date
                createDatePicker(for: toDateView, date: Date(), minimumDate: datePicker.date)
                toDateView.updateData(text: "")
                toDateView.endEditing(true)
            } else {
                selectedEndDate = datePicker.date
                enableSaveButton()
            }
        }
        textField.endEditing(true)
    }
    
    @objc func cancelPicker() {
        fromDateView.endEditing(true)
        toDateView.endEditing(true)
    }
    
    func enableSaveButton() {
        saveButton.isUserInteractionEnabled = true
        saveButton.alpha = 1.0
    }
    
    func disableSaveButton() {
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.3
    }
    func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisTimeSelector.titleLabel
    }
    
    func getPreSelectedIndex() -> Int {
        switch self.selectedType {
        case .monthly:
            return 0
        case .quarterly:
            return 1
        case .annual:
            return 2
        case .custom:
            return 3
        default:
            return 0
        }
    }
    
    func enabledDateMode() {
        dateSelectorStack.isHidden = false
    }
}

extension TimePeriodSelectorViewController: HorizontalSelectorViewDelegate {
    func didSelectItem(at index: Int) {
        switch index {
        case 0:
            dateSelectorStack.isHidden = true
            selectedType = .monthly
        case 1:
            dateSelectorStack.isHidden = true
            selectedType = .quarterly
        case 2:
            dateSelectorStack.isHidden = true
            selectedType = .annual
        case 3: // custom time period
            dateSelectorStack.isHidden = false
            selectedType = .custom
        default:
            break
        }
        enableSaveButton()
        fromDateView.endEditing(true)
        toDateView.endEditing(true)
    }
}
