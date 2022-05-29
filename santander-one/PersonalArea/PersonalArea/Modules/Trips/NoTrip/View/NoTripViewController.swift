//
//  NoTripViewController.swift
//  PersonalArea
//
//  Created by alvola on 16/03/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol NoTripViewProtocol: UIViewController, NavigationBarWithSearchProtocol {
    func setupViewModel(_ viewModel: CountriesListViewModel)
    func showComingSoonToast()
    func showToolTip(isInitialToolTip: Bool)
}

final class NoTripViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var addNextTripLabel: UILabel!
    @IBOutlet private weak var destinationLabel: UILabel!
    @IBOutlet private weak var tripTypeLabel: UILabel!
    @IBOutlet private weak var departureTitleLabel: UILabel!
    @IBOutlet private weak var segmentedControl: LisboaSegmentedControl!
    @IBOutlet private weak var countriesField: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var innerView: UIView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var button: RedLisboaButton!
    private let presenter: NoTripPresenterProtocol
    private var dropdown: DropdownView<CountryDropdownModel>?
    
    private let startDateView = TripDatePickerView()
    private let endDateView = TripDatePickerView()
    
    private var textFieldStyle: LisboaTextFieldStyle {
        var fieldStyle = LisboaTextFieldStyle.default
        fieldStyle.containerViewBackgroundColor = UIColor.black.withAlphaComponent(0.35)
        fieldStyle.extraInfoViewBackgroundColor = UIColor.clear
        fieldStyle.extraInfoHorizontalSeparatorBackgroundColor = .white
        fieldStyle.verticalSeparatorBackgroundColor = .clear
        fieldStyle.fieldFont = UIFont.santander(family: .text, type: .regular, size: 20.0)
        fieldStyle.titleLabelTextColor = .white
        fieldStyle.containerViewBorderColor = UIColor.brownGray.cgColor
        fieldStyle.containerViewBorderWidth = 2.0
        
        return fieldStyle
    }

    private let currentDate = Date()
    
    private var selectedCountry: CountryDropdownModel?
     
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: NoTripPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public var isSearchEnabled: Bool = false {
        didSet {
            configureNavigationBar()
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        tapGesture.delegate = self
        self.scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyBoard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.viewDidAppear()
    }
    
    // MARK: - privateMethods
    private func setup() {
        setupViews()
        setupLabels()
        setupTextFields()
        setupButton()
    }
    
    private func setupViews() {
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.image = Assets.image(named: "bg_travel")
        innerView.backgroundColor = .white
        innerView.alpha = 0.22
        innerView.layer.borderColor = UIColor.mediumSky.cgColor
        innerView.layer.cornerRadius = 6.0
        innerView.layer.borderWidth = 1.0
    }
    
    private func setupLabels() {
        _ = [titleLabel,
        subtitleLabel,
        destinationLabel,
        addNextTripLabel,
        tripTypeLabel,
        departureTitleLabel].compactMap { $0?.text = ""; $0?.textColor = .white }
        
        titleLabel.configureText(withKey: "yourTrips_title_bank",
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 24)))
        
        subtitleLabel.configureText(withKey: "yourTrips_text_bank",
                                    andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14)))
        
        addNextTripLabel.configureText(withKey: "yourTrips_title_add",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 20)))

        destinationLabel.configureText(withKey: "yourTrips_label_where",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 17)))

        departureTitleLabel.configureText(withKey: "yourTrips_label_when",
                                          andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 17)))

        tripTypeLabel.configureText(withKey: "yourTrips_label_type",
                                    andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 17)))
    }
    
    private func setupTextFields() {
        configureDropdown()
        configureDateFields()
    }
    
    private func configureDropdown() {
        countriesField.backgroundColor = .clear
        countriesField.layer.borderColor = textFieldStyle.containerViewBorderColor
        countriesField.layer.borderWidth = textFieldStyle.containerViewBorderWidth
        let dropdown = DropdownView<CountryDropdownModel>(frame: .zero)
        dropdown.backgroundColor = textFieldStyle.containerViewBackgroundColor
        dropdown.style = .trips()
        countriesField.addSubview(dropdown)
        dropdown.fullFit()
        dropdown.delegate = self
        self.dropdown = dropdown
    }
    
    private func setupButton() {
        button.setTitle(localized("yourTrips_button_addTrip"), for: .normal)
        button.addAction { [weak self] in
            self?.didPressSaveButton()
        }
    }
    
    private func didPressSaveButton() {
        guard let countryCode = self.selectedCountry?.code else { return }
        let startPickerDate = self.startDateView.pickerDate
        let endPickerDate = self.endDateView.pickerDate
        let newTripInput = NewTripInput(countryCode: countryCode,
                                        fromDate: startPickerDate,
                                        toDate: endPickerDate,
                                        selectedSegmentIndex: self.segmentedControl.selectedSegmentIndex)
        self.presenter.createTripWith(newTripInput)
    }
    
    private func configureDateFields() {
        let endDate = Calendar.current.date(
            byAdding: DateComponents(day: 7),
            to: currentDate
        ) ?? currentDate
        let maximunEndDate = Calendar.current.date(
            byAdding: DateComponents(year: 1),
            to: currentDate
        ) ?? currentDate
        startDateView.setInfo(
            TripDatePickerViewModel(
                title: localized("search_label_since"),
                minDate: currentDate,
                currentDate: currentDate,
                maxDate: nil
            )
        )
        startDateView.delegate = self
        endDateView.setInfo(
            TripDatePickerViewModel(
                title: localized("search_label_until"),
                minDate: currentDate,
                currentDate: endDate,
                maxDate: maximunEndDate
            )
        )
        endDateView.delegate = self
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12.0
        stackView.addArrangedSubview(startDateView)
        stackView.addArrangedSubview(endDateView)
    }

    private func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .clear(tintColor: .white),
            title: .tooltip(
                titleKey: "toolbar_title_yourTrips",
                type: .white,
                action: { [weak self] sender in
                    self?.didSelectToollTip(sender)
                }
            )
        )
        builder.setLeftAction(.back(action: #selector(backButtonPressed)))
        builder.setRightActions(.menu(action: #selector(menuPressed)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func backButtonPressed() { presenter.backButtonPressed() }
    @objc func searchButtonPressed() { presenter.searchButtonPressed() }
    @objc private func menuPressed() { presenter.menuPressed() }
    @objc private func didSelectToollTip(_ sender: UIView) {
        TripModeInfoTooltip().showTooltip(in: self, from: sender, isInitialToolTip: false)
    }
}

extension NoTripViewController: NoTripViewProtocol {
    
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
    
    func setupViewModel(_ viewModel: CountriesListViewModel) {
        self.segmentedControl.setupMultiLineWithStylableText(
            with: [localized("yourTrips_tab_pleasure"),
                   localized("yourTrips_tab_business")],
            withStyle: .tripModeSegmentedControlStyle)
        let dropdownConfiguration = DropdownConfiguration<CountryDropdownModel>(
            title: localized("generic_hint_selectCountry"),
            elements: viewModel.countries,
            displayMode: .growToScreenBounds(inset: 20))
        self.dropdown?.configure(dropdownConfiguration)
        self.selectedCountry = viewModel.countries.first
    }
    
    func showComingSoonToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func showToolTip(isInitialToolTip: Bool) {
        guard let toolTipButton = navigationItem.titleView as? ToolTipButton else { return }
        TripModeInfoTooltip().showTooltip(in: self, from: toolTipButton, isInitialToolTip: isInitialToolTip)
    }
}

extension NoTripViewController: DropdownDelegate {
    func didSelectOption(element: DropdownElement) {
        guard let element = element as? CountryDropdownModel else { return }
        selectedCountry = element
    }
}

extension NoTripViewController: RootMenuController {
    var isSideMenuAvailable: Bool { true }
}

extension NoTripViewController: TripDatePickerViewProtocol {
    
    func datePickerView(_ datePickerView: TripDatePickerView, didSelect date: Date) {
        
        guard startDateView == datePickerView else { return }
        
        let startDate = startDateView.pickerDate
        let endDate = endDateView.pickerDate
        
        if startDate > endDate {
            let endDate: Date = Calendar.current.date(byAdding: DateComponents(day: 7),
                                                      to: startDate) ?? Date()
            endDateView.set(currentDate: endDate)
        }
        
        endDateView.set(minimunDate: startDate)
        endDateView.set(maximumDate: Calendar.current.date(byAdding: DateComponents(year: 1),
                                                           to: startDate) ?? Date())
    }
}

extension NoTripViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let tableView = self.scrollView.subviews.filter({ $0 is UITableView }).first else { return true }
        return !(touch.view?.isDescendant(of: tableView) == true)
    }
}
