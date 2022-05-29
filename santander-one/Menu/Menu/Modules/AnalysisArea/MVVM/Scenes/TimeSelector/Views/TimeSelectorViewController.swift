//
//  TimeSelectorViewController.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 27/1/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import UIOneComponents
import CoreFoundationLib
import CoreDomain

final class TimeSelectorViewController: UIViewController {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var oneAlertView: OneAlertView!
    @IBOutlet private weak var temporalStackView: UIStackView!
    @IBOutlet private weak var dateStackView: UIStackView!
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    private let viewModel: TimeSelectorViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: TimeSelectorDependenciesResolver
    var loadingView: UIView?
    private lazy var startDateOneSelectView: DateOneSelectView = {
        let startDatViewModel = OneInputDateViewModel(dependenciesResolver: self.dependencies.external.resolve(),
                                                      status: .activated,
                                                      minDate: Date(timeIntervalSince1970: 1567296000),
                                                      maxDate: Date(timeIntervalSinceNow: 0),
                                                      accessibilitySuffix: "_financialHealth",
                                                      accessibilityLabelKey: "voiceover_startDateApplied",
                                                      accessibilityInputKey: "_startDate")
        let view = DateOneSelectView(frame: .zero)
        view.setViewModel(startDatViewModel, titleDescriptionKey: localized("generic_label_startDate"))
        view.clearDateTextField()
        return view
    }()
    private lazy var endDateOneSelectView: DateOneSelectView = {
        let endDateViewModel = OneInputDateViewModel(dependenciesResolver: self.dependencies.external.resolve(),
                                                     status: .activated,
                                                     firstDate: Date(timeIntervalSinceNow: 0),
                                                     minDate: Date(timeIntervalSince1970: 1567296000),
                                                     maxDate: Date(timeIntervalSinceNow: 0),
                                                     accessibilitySuffix: "_financialHealth",
                                                     accessibilityLabelKey: "voiceover_endDateApplied",
                                                     accessibilityInputKey: "_endDate")
        let view = DateOneSelectView(frame: .zero)
        view.setViewModel(endDateViewModel, titleDescriptionKey: localized("generic_label_endDate"))
        return view
    }()
    
    init(dependencies: TimeSelectorDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "TimeSelectorViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
        setAppearance()
        setAccessibilityIdentifiers()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    @IBAction func didTapConfirmButton(_ sender: Any) {
        viewModel.didTapConfirm()
    }
}

private extension TimeSelectorViewController {
    func setAppearance() {
        self.descriptionLabel.font = .typography(fontName: .oneH100Bold)
        self.descriptionLabel.text = localized("analysis_label_chosenTemporalView")
        self.descriptionLabel.textColor = .oneLisboaGray
        self.configureAlertView()
        self.configureTemporalView()
        self.configureDateView()
        self.view.layoutIfNeeded()
    }
    
    func configureAlertView() {
        self.oneAlertView.setType(
            .textAndImage(imageKey: "icnInfo",
                          stringKey: "analysis_label_temporaryConfiguration")
        )
    }
    
    func configureTemporalView() {        
        TimeViewOptions.allCases.enumerated().forEach { (index, timeView) in
            let modelItem = OneSmallSelectorListViewModel(leftTextKey: localized(timeView.timeViewLocalizedKey),
                                                          rightAccessory: .none,
                                                          status: .inactive,
                                                          accessibilitySuffix: timeView.timeViewLocalizedKey)
            let smallSelectorListView = OneSmallSelectorListView()
            smallSelectorListView.setViewModel(modelItem, index: index)
            smallSelectorListView.delegate = self
            self.temporalStackView.addArrangedSubview(smallSelectorListView)
        }
    }
        
    func configureDateView() {
        self.dateStackView.addArrangedSubview(startDateOneSelectView)
        self.dateStackView.addArrangedSubview(endDateOneSelectView)
    }
    
    func bind() {
        bindTimeViewOptions()
        bindDateOneSelectView()
        bindDateSelectedViews()
    }
    
    func bindTimeViewOptions() {
        viewModel.state
            .case { TimeSelectorState.updateTimeViewSelected }
            .sink { [unowned self] timeOptionSelected in
                setTimeViewOptions(with: timeOptionSelected)
            }.store(in: &subscriptions)
        
        viewModel.state
            .case { TimeSelectorState.isEnableConfirmDates }
            .sink { [unowned self] isEnabled in
                self.setFloatingButton(isEnabled: isEnabled)
            }.store(in: &subscriptions)
    }
    
    func bindDateOneSelectView() {
        startDateOneSelectView
            .publisher
            .sink { [unowned self] date in
                self.endDateOneSelectView.setMinDate(date)
                self.viewModel.didStartDateChanged(date)
            }.store(in: &subscriptions)
        
        endDateOneSelectView
            .publisher
            .sink { date in
                self.viewModel.didEndDateChanged(date)
            }.store(in: &subscriptions)
    }
    
    func bindDateSelectedViews() {
        viewModel.state
            .case { TimeSelectorState.updateSelectedDates }
            .sink { [unowned self] in
                self.setDateViews(startDate: $0.startDate, endDate: $0.endDate)
            }.store(in: &subscriptions)
    }
    
    func configureNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_chooseTemporaryView")
            .setLeftAction(.back)
            .setRightAction(.close, action: close)
            .build(on: self)
    }
    
    @objc func close() {
        viewModel.close()
    }
    
    func setupComponents() {
        self.floatingButton.configureWith(
            type: .primary,
            size: .medium(OneFloatingButton.ButtonSize.MediumButtonConfig(title: localized("generic_button_confirm"),
                                                                          icons: .none,
                                                                          fullWidth: false)),
            status: .ready)
        self.isEnabledConfirmButton(true)
    }
    
    func isEnabledConfirmButton(_ isEnabled: Bool) {
        self.floatingButton.isEnabled = isEnabled
    }
    
    func setTimeViewOptions(with timeViewOption: TimeViewOptions) {
        unselectOptions()
        guard let timeSelectorListViewOption = self.temporalStackView.subviews[timeViewOption.elementIndex()] as? OneSmallSelectorListView else { return }
        timeSelectorListViewOption.setStatus(.activated)
        switch timeViewOption {
        case .customized:
            setCustomizeOptionsVisibility(isHidden: false)
        default:
            setCustomizeOptionsVisibility(isHidden: true)
        }
    }
    
    func unselectOptions() {
        self.temporalStackView.subviews.forEach { view in
            guard let timeViewOption = view as? OneSmallSelectorListView else { return }
            timeViewOption.setStatus(.inactive)
        }
    }
    
    func setCustomizeOptionsVisibility(isHidden: Bool) {
        self.dateStackView.isHidden = isHidden
        self.floatingButton.isHidden = isHidden
    }
    
    func setFloatingButton(isEnabled: Bool) {
        self.floatingButton.isEnabled = isEnabled
    }
    
    func setDateViews(startDate: Date, endDate: Date) {
        let startDateViewModel = OneInputDateViewModel(dependenciesResolver: self.dependencies.external.resolve(),
                                                       status: .activated,
                                                       firstDate: startDate,
                                                       minDate: Date(timeIntervalSince1970: 1567296000),
                                                       maxDate: Date(timeIntervalSinceNow: 0),
                                                       accessibilitySuffix: "_financialHealth",
                                                       accessibilityLabelKey: "voiceover_startDateApplied",
                                                       accessibilityInputKey: "_startDate")
        let endDateViewModel = OneInputDateViewModel(dependenciesResolver: self.dependencies.external.resolve(),
                                                     status: .activated,
                                                     firstDate: endDate,
                                                     minDate: startDate,
                                                     maxDate: Date(timeIntervalSinceNow: 0),
                                                     accessibilitySuffix: "_financialHealth",
                                                     accessibilityLabelKey: "voiceover_endDateApplied",
                                                     accessibilityInputKey: "_endDate")
        self.startDateOneSelectView.setViewModel(startDateViewModel, titleDescriptionKey: localized("generic_label_startDate"))
        self.endDateOneSelectView.setViewModel(endDateViewModel, titleDescriptionKey: localized("generic_label_endDate"))
    }
    
    func setAccessibilityInfo() {
        self.floatingButton.accessibilityLabel = localized("voiceover_confirmBackAnalysis")
        UIAccessibility.post(notification: .layoutChanged, argument: self.navigationItem.titleView)
    }
    
    func setAccessibilityIdentifiers() {
        self.descriptionLabel.accessibilityIdentifier = AccessibilityAnalysisAreaTimeSelector.analysisLabelChosenTemporalView
    }
}

extension TimeSelectorViewController: OneSmallSelectorListViewDelegate {
    func didSelectOneSmallSelectorListView(status: OneSmallSelectorListViewModel.Status, at index: Int) {
        viewModel.didTapOnTimeView(index: index)
    }
}

extension TimeSelectorViewController: AccessibilityCapable {}
