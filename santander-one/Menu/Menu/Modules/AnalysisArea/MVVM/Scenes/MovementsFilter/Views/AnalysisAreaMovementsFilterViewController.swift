//
//  MovementsFilterViewController.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 4/4/22.
//

import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import UIOneComponents

final class AnalysisAreaMovementsFilterViewController: UIViewController {
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    private let viewModel: AnalysisAreaMovementsFilterViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: AnalysisAreaMovementsFilterDependenciesResolver
    private var nameFilterValue = ""
    private var startDateFilterValue: Date?
    private var endDateFilterValue: Date?
    private var startAmountFilterValue: Decimal?
    private var endAmountFilterValue: Decimal?
    private var isApplicable = false {
        didSet {
            floatingButton.isEnabled = isApplicable
        }
    }
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setSpacing(24)
        return view
    }()
    private lazy var nameFilterStackView = UIStackView()
    private lazy var nameFilterTextField = OneInputRegularView()
    private lazy var dateFilterStackView =  UIStackView()
    private lazy var startDateFilterInput = DateOneSelectView()
    private lazy var endDateFilterInput = DateOneSelectView()
    private lazy var amountFilterStackView = UIStackView()
    private lazy var startAmountFilterInput = OneInputAmountView()
    private lazy var endAmountFilterInput = OneInputAmountView()
    private lazy var errorAmountFilterView: UIStackView = {
        let stack = UIStackView()
        stack.isHidden = true
        return stack
    }()
    
    init(dependencies: AnalysisAreaMovementsFilterDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "AnalysisAreaMovementsFilterViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
}

private extension AnalysisAreaMovementsFilterViewController {
    func setAppearance() {
        configureScrollableStack()
        configureNameFilterStackView()
        configureDateFilterStackView()
        configureAmountFilterStackView()
        configureFloatingButton()
        configureParentView()
        addSubviews()
    }
    
    func addSubviews() {
        scrollableStackView.addArrangedSubview(nameFilterStackView)
        scrollableStackView.addArrangedSubview(dateFilterStackView)
        scrollableStackView.addArrangedSubview(amountFilterStackView)
        let subviews = scrollableStackView.getArrangedSubviews()
        subviews.forEach {
            $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
            $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        }
    }
    
    func bind() {
        bindViewModel()
        bindNameFilterTextField()
        bindDateFilterTextFields()
        bindAmountFilterTextFields()
    }
    
    func bindViewModel() {
        viewModel.state
            .case(AnalysisAreaMovementsFilterState.setFiltersApplied)
            .sink { [unowned self] filters in
                setFiltersAppliedInfo(filters)
            }.store(in: &subscriptions)
    }
    
    func bindNameFilterTextField() {
        nameFilterTextField.publisher
            .case(ReactiveOneInputRegularViewState.textDidChange)
            .sink { [unowned self] text in
                nameFilterValue = text
            }.store(in: &subscriptions)
        
        nameFilterTextField.publisher
            .case(ReactiveOneInputRegularViewState.didEndEditing)
            .sink { [unowned self] _ in
                checkAllFiltersValue()
            }.store(in: &subscriptions)
    }
    
    func bindDateFilterTextFields() {
        startDateFilterInput.publisher
            .sink { [unowned self] date in
                startDateFilterValue = date
                checkAllFiltersValue()
                endDateFilterInput.setMinDate(date)
            }.store(in: &subscriptions)
        
        endDateFilterInput.publisher
            .sink { [unowned self] date in
                endDateFilterValue = date
                checkAllFiltersValue()
            }.store(in: &subscriptions)
    }
    
    func bindAmountFilterTextFields() {
        startAmountFilterInput.publisher
            .case(ReactiveOneInputAmountViewState.textFieldDidEndEditing)
            .sink { [unowned self] _ in
                startAmountFilterValue = Decimal(string: startAmountFilterInput.getAmount())
                checkAllFiltersValue()
            }.store(in: &subscriptions)
            
        endAmountFilterInput.publisher
            .case(ReactiveOneInputAmountViewState.textFieldDidEndEditing)
            .sink { [unowned self] _ in
                endAmountFilterValue = Decimal(string: endAmountFilterInput.getAmount())
                checkAllFiltersValue()
            }.store(in: &subscriptions)
    }
    
    func configureParentView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    func configureNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_filters")
            .setLeftAction(.back)
            .setRightAction(.close, action: didTapCloseButton)
            .build(on: self)
    }
    
    func configureScrollableStack() {
        view.addSubview(scrollableStackView)
        scrollableStackView.setScrollDelegate(self)
        scrollableStackView.setup(with: self.view)
        self.view.bringSubviewToFront(floatingButton)
    }
    
    func configureNameFilterStackView() {
        nameFilterStackView.axis = .vertical
        nameFilterStackView.distribution = .fill
        nameFilterStackView.alignment = .fill
        nameFilterStackView.spacing = 8
        configureNameFilterTextfield()
        let label = UILabel()
        label.text = localized("search_label_movementName")
        label.font = .typography(fontName: .oneB400Bold)
        label.accessibilityIdentifier = "search_label_movementName"
        nameFilterStackView.isLayoutMarginsRelativeArrangement = true
        nameFilterStackView.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        nameFilterStackView.addArrangedSubview(label)
        nameFilterStackView.addArrangedSubview(nameFilterTextField)
    }
    
    func configureNameFilterTextfield() {
        nameFilterTextField.setupTextField(
            OneInputRegularViewModel(
                status: .activated,
                placeholder: localized("search_label_nameMovement"),
                searchAction: {},
                resetText: true,
                alignment: .leading,
                accessibilitySuffix: "analysisArea_categoryDetail_filtersMovement_filterName"))
        nameFilterTextField.maxCounter = 30
        let literalRegex = localized("digits_filters").replaceFirst("\\", "")
        let regex = "[\(literalRegex))]"
        nameFilterTextField.regularExpression = try? NSRegularExpression(pattern: regex)
    }
    
    func configureDateFilterStackView() {
        dateFilterStackView.axis = .vertical
        dateFilterStackView.distribution = .fill
        dateFilterStackView.alignment = .fill
        let label = UILabel()
        label.text = localized("search_label_datesRange")
        label.font = .typography(fontName: .oneB400Bold)
        label.accessibilityIdentifier = "search_label_datesRange"
        dateFilterStackView.addArrangedSubview(label)
        configureDatesInputsHorizontalStack()
    }
    
    func configureDatesInputsHorizontalStack() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 16
        configureStartDateInput()
        configureEndDateInput()
        stack.addArrangedSubview(startDateFilterInput)
        stack.addArrangedSubview(endDateFilterInput)
        dateFilterStackView.addArrangedSubview(stack)
    }
    
    func configureStartDateInput() {
        startDateFilterInput.setViewModel(
            OneInputDateViewModel(dependenciesResolver: self.dependencies.external.resolve(),
                                  status: .activated,
                                  minDate: Date(timeIntervalSince1970: 1567296000),
                                  maxDate: Date(timeIntervalSinceNow: 0),
                                  accessibilitySuffix: "_financialHealth_categoryDetail_filter",
                                  accessibilityInputKey: "_startDate"),
            titleDescriptionKey: localized("generic_label_startDate"))
        startDateFilterInput.clearDateTextField()
    }
    
    func configureEndDateInput() {
        endDateFilterInput.setViewModel(
            OneInputDateViewModel(dependenciesResolver: self.dependencies.external.resolve(),
                                  status: .activated,
                                  minDate: Date(timeIntervalSince1970: 1567296000),
                                  maxDate: Date(timeIntervalSinceNow: 0),
                                  accessibilitySuffix: "_financialHealth_categoryDetail_filter",
                                  accessibilityInputKey: "_endDate"),
            titleDescriptionKey: localized("generic_label_endDate"))
        endDateFilterInput.clearDateTextField()
    }
    
    func configureAmountFilterStackView() {
        amountFilterStackView.axis = .vertical
        amountFilterStackView.distribution = .fill
        amountFilterStackView.alignment = .fill
        amountFilterStackView.spacing = 8
        let label = UILabel()
        label.text = localized("search_label_value")
        label.font = .typography(fontName: .oneB400Bold)
        label.accessibilityIdentifier = "search_label_value"
        amountFilterStackView.isLayoutMarginsRelativeArrangement = true
        amountFilterStackView.layoutMargins = UIEdgeInsets(top: -16, left: 0, bottom: 0, right: 0)
        amountFilterStackView.addArrangedSubview(label)
        configureAmountsLabelsHorizontalStack()
        configureAmountsInputsHorizontalStack()
    }
    
    func configureAmountsLabelsHorizontalStack() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .leading
        stack.spacing = 16
        let startLabel = UILabel()
        let endLabel = UILabel()
        startLabel.text = localized("search_label_since")
        startLabel.textColor = .oneLisboaGray
        startLabel.font = .typography(fontName: .oneB300Regular)
        startLabel.accessibilityIdentifier = "search_label_since"
        endLabel.text = localized("search_label_until")
        endLabel.textColor = .oneLisboaGray
        endLabel.font = .typography(fontName: .oneB300Regular)
        endLabel.accessibilityIdentifier = "search_label_until"
        stack.addArrangedSubview(startLabel)
        stack.addArrangedSubview(endLabel)
        amountFilterStackView.addArrangedSubview(stack)
    }
    
    func configureAmountsInputsHorizontalStack() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 16
        configureStartAmountInput()
        configureEndAmountInput()
        stack.addArrangedSubview(startAmountFilterInput)
        stack.addArrangedSubview(endAmountFilterInput)
        amountFilterStackView.addArrangedSubview(stack)
        configureErrorAmountView()
    }
    
    func configureErrorAmountView() {
        errorAmountFilterView.axis = .horizontal
        errorAmountFilterView.spacing = 8
        errorAmountFilterView.alignment = .top
        errorAmountFilterView.distribution = .fill
        let label = UILabel()
        label.font = .typography(fontName: .oneB300Regular)
        label.textColor = .oneSantanderRed
        label.text = localized("analysis_alert_amountLimit")
        label.numberOfLines = 0
        let icon = UIImageView()
        icon.image = Assets.image(named: "oneIcnAlert")?.withRenderingMode(.alwaysOriginal)
        icon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 25).isActive = true
        icon.contentMode = .scaleAspectFit
        errorAmountFilterView.addArrangedSubview(icon)
        errorAmountFilterView.addArrangedSubview(label)
        amountFilterStackView.addArrangedSubview(errorAmountFilterView)
    }
    
    func configureStartAmountInput() {
        startAmountFilterInput.setupTextField(
            OneInputAmountViewModel(
                status: .activated,
                type: .icon,
                placeholder: "0,00",
                accessibilitySuffix: "_financialHealth_categoryDetail_filter_startAmount"))
    }
    
    func configureEndAmountInput() {
        endAmountFilterInput.setupTextField(
            OneInputAmountViewModel(
                status: .activated,
                type: .icon,
                placeholder: "0,00",
                accessibilitySuffix: "_financialHealth_categoryDetail_filter_endAmount"))
    }
    
    func configureFloatingButton() {
        floatingButton.configureWith(type: .primary,
                                     size: .medium(OneFloatingButton.ButtonSize.MediumButtonConfig(title: localized("generic_button_apply"),
                                                                                                   icons: .none, fullWidth: false)),
                                     status: .ready)
        floatingButton.isEnabled = false
    }
    
    func checkAllFiltersValue() {
        let applyEnable = nameFilterValue.isNotEmpty || checkDatesFiltersValues() || checkAmountFiltersValues()
        isApplicable = applyEnable
    }
    
    func checkDatesFiltersValues() -> Bool {
        !startDateFilterValue.isNil && !endDateFilterValue.isNil
    }
    
    func checkAmountFiltersValues() -> Bool {
        startAmountFilterValue = startAmountFilterInput.getAmount().stringToDecimal
        endAmountFilterValue = endAmountFilterInput.getAmount().stringToDecimal
        if startAmountFilterValue.isNil {
            return !endAmountFilterValue.isNil
        }
        guard let startValue = startAmountFilterValue else { return false }
        let condition = endAmountFilterValue.isNil || (startValue.isLessThanOrEqualTo(endAmountFilterValue ?? 0.0))
        if !condition {
            startAmountFilterValue = nil
            endAmountFilterValue = nil
        }
        startAmountFilterInput.status = condition ? .activated : .error
        errorAmountFilterView.isHidden = condition
        return condition ? true : false
    }
    
    func setFiltersAppliedInfo(_ filter: AnalysisAreaFilterRepresentable) {
        nameFilterTextField.setInputText(filter.transactionDescription)
        nameFilterValue = filter.transactionDescription ?? ""
        startAmountFilterInput.setAmount(filter.fromAmount?.getStringValue() ?? "")
        startAmountFilterValue = filter.fromAmount
        endAmountFilterInput.setAmount(filter.toAmount?.getStringValue() ?? "")
        endAmountFilterValue = filter.toAmount
        startDateFilterInput.setDate(filter.fromDate ?? nil)
        startDateFilterValue = filter.fromDate
        endDateFilterInput.setDate(filter.toDate ?? nil)
        endDateFilterValue = filter.toDate
        checkAllFiltersValue()
    }
    
    func setAccessibilityIdentifiers() {
        floatingButton.setAccessibilitySuffix(AnalysisAreaAccessibility.analysisFiltersFloatingButton)
        nameFilterTextField.accessibilityIdentifier = AnalysisAreaAccessibility.analysisFiltersNameFilter
        startDateFilterInput.accessibilityIdentifier = AnalysisAreaAccessibility.analysisFiltersStartDate
        endDateFilterInput.accessibilityIdentifier = AnalysisAreaAccessibility.analysisFiltersEndDate
        startAmountFilterInput.accessibilityIdentifier = AnalysisAreaAccessibility.analysisFiltersStartAmount
        endAmountFilterInput.accessibilityIdentifier = AnalysisAreaAccessibility.analysisFiltersEndAmount
    }
    
    @objc func didTapCloseButton() {
        viewModel.didTapCloseButton()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func didTapApply(_ sender: Any) {
        let nameFilter = nameFilterValue.isNotEmpty ? nameFilterValue : nil
        let representable = DefaultAnalysisAreaFilter(fromAmount: startAmountFilterValue,
                                  toAmount: endAmountFilterValue,
                                  fromDate: startDateFilterValue,
                                  toDate: endDateFilterValue,
                                  description: nameFilter)
        viewModel.didTapApply(representable)
    }
}

extension AnalysisAreaMovementsFilterViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            navigationController?.navigationBar.setOneShadows(type: .oneShadowLarge)
        } else {
            navigationController?.navigationBar.setOneShadows(type: .none)
        }
    }
}
