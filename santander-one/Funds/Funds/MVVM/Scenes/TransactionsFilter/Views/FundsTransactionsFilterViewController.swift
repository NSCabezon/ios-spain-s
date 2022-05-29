//
//  FundsTransactionsFilterViewController.swift
//  Funds
//

import UIKit
import CoreFoundationLib
import UI
import OpenCombine
import CoreDomain
import UIOneComponents

final class FundsTransactionsFilterViewController: UIViewController {
    lazy var scrollableStackView = ScrollableStackView(frame: .zero)
    @IBOutlet private weak var searchScrollView: UIScrollView!
    @IBOutlet private weak var dateFilterContainerView: UIView!
    @IBOutlet private weak var dateFilterLabel: UILabel!
    @IBOutlet private weak var fromDateLabel: UILabel!
    @IBOutlet private weak var fromInputDateView: OneInputDateView!
    @IBOutlet private weak var toDateLabel: UILabel!
    @IBOutlet private weak var toInputDateView: OneInputDateView!
    @IBOutlet private weak var applyButtonView: UIView!
    @IBOutlet private weak var applyButton: OneFloatingButton!
    private let dependencies: FundsTransactionsFilterDependenciesResolver
    private let viewModel: FundsTransactionsFilterViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let fromDateDelegate = DateDelegate()
    private let toDateDelegate = DateDelegate()
    var newFilters = TransactionFiltersEntity()
    var currentLanguage: String
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(dependencies: FundsTransactionsFilterDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        let stringLoader: StringLoader = dependencies.external.resolve()
        self.currentLanguage = stringLoader.getCurrentLanguage().languageType.rawValue
        super.init(nibName: "FundsTransactionsFilterViewController", bundle: .module)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setAccessibilityIdentifiers()
        self.bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
        self.hideKeyboardWhenTappedAround()
        self.fromInputDateView.delegate = self.fromDateDelegate
        self.toInputDateView.delegate = self.toDateDelegate
    }
}

private extension FundsTransactionsFilterViewController {
    func setupView() {
        self.setupDateFilter()
        let mediumButtonConfig = OneFloatingButton.ButtonSize.MediumButtonConfig(title: "generic_button_apply", icons: .none, fullWidth: false)
        self.applyButton.configureWith(type: .primary, size: .medium(mediumButtonConfig), status: .ready)
    }

    func setupDateFilter() {
        self.dateFilterLabel.text = localized("search_label_datesRange")
        self.fromDateLabel.text = localized("search_label_since")
        self.toDateLabel.text = localized("search_label_until")
    }
    
    @IBAction func clickContinueButton(_ sender: UIButton) {
        self.viewModel.returnWithFilters()
    }
    
    func setupNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_filters")
            .setLeftAction(.back, customAction: { [weak self] in
                self?.viewModel.trackEvent(.back)
                self?.viewModel.close()
            })
            .setRightAction(.close) { [weak self] in
                self?.viewModel.trackEvent(.close)
                self?.viewModel.close()
            }
            .build(on: self)
    }
    
    func hideKeyboardWhenTappedAround() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.cancelsTouchesInView = false
        self.view?.addGestureRecognizer(gesture)
    }
    
    @objc func hideKeyboard() {
        view?.endEditing(true)
    }
    
    func bind() {
        self.bindInitialFilters()
        self.bindDateFilters()
        self.bindFiltersChanged()
    }
    
    func bindInitialFilters() {
        self.viewModel.state
            .case(FundsTransactionsFilterState.initialFilters)
            .sink { [unowned self ] filters in
                self.setFilters(filters: filters)
            }.store(in: &subscriptions)
    }

    func bindDateFilters() {
        self.fromDateDelegate
            .didSelectNewDate
            .sink { fromDate in
                self.viewModel.updateDateRangeFilters(fromDate: fromDate)
            }.store(in: &subscriptions)

        self.toDateDelegate
            .didSelectNewDate
            .sink { toDate in
                self.viewModel.updateDateRangeFilters(toDate: toDate)
            }.store(in: &subscriptions)
    }

    func bindFiltersChanged() {
        self.viewModel.state
            .case(FundsTransactionsFilterState.filtersChanged)
            .sink { [unowned self] filters in
                self.setFilters(filters: filters)
            }.store(in: &subscriptions)
    }

    func setFilters(filters: TransactionFiltersEntity) {
        let fromDate = filters.getDateRange()?.fromDate
        let toDate = filters.getDateRange()?.toDate ?? Date()
        self.setDateFilter(self.fromInputDateView, withDate: fromDate, minDate: self.viewModel.minDateFilter, maxDate: toDate,
                           accessibilitySuffix: AccessibilityIdFundsTransactionsFilter.startDateSuffix.rawValue)
        self.setDateFilter(self.toInputDateView, withDate: toDate, minDate: fromDate ?? self.viewModel.minDateFilter, maxDate: Date(),
                           accessibilitySuffix: AccessibilityIdFundsTransactionsFilter.endDateSuffix.rawValue)
        self.applyButton.isEnabled = self.viewModel.isAnyFilterActive
    }

    func setDateFilter(_ dateFilter: OneInputDateView, withDate date: Date?, minDate: Date? = nil, maxDate: Date? = nil, accessibilitySuffix: String) {
        let oneInputDateViewModel = OneInputDateViewModel(
            dependenciesResolver: self.dependencies.external.resolve(),
            status: date.isNil ? .inactive : .activated,
            firstDate: date,
            minDate: minDate,
            maxDate: maxDate,
            accessibilitySuffix: accessibilitySuffix)
        dateFilter.setViewModel(oneInputDateViewModel)
    }

    func setAccessibilityIdentifiers() {
        dateFilterLabel.accessibilityIdentifier = AccessibilityIdFundsTransactionsFilter.searchLabelDatesRange.rawValue
        fromDateLabel.accessibilityIdentifier = AccessibilityIdFundsTransactionsFilter.searchLabelSince.rawValue
        toDateLabel.accessibilityIdentifier = AccessibilityIdFundsTransactionsFilter.searchLabelUntil.rawValue
        self.applyButton.accessibilityIdentifier = AccessibilityLoansFilter.applyButton
        self.applyButtonView.accessibilityIdentifier = AccessibilityLoansFilter.applyButtonView
        self.setAccessibility {
            self.applyButton.accessibilityLabel = localized("generic_button_apply")
        }
        self.accessibilityElements = [dateFilterLabel, fromDateLabel, fromInputDateView, toDateLabel, toInputDateView, applyButton]
    }
}

private extension FundsTransactionsFilterViewController {
    class DateDelegate: OneInputDateViewDelegate {
        let didSelectNewDate = PassthroughSubject<Date, Never>()

        func didSelectNewDate(_ dateValue: Date) {
            self.didSelectNewDate.send(dateValue)
        }

        func didSelectCancelOption() {}
    }
}

extension FundsTransactionsFilterViewController: OldDialogViewPresentationCapable { }

extension FundsTransactionsFilterViewController: AccessibilityCapable {}
