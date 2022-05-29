//
//  NoTripPresenter.swift
//  PersonalArea
//
//  Created by alvola on 16/03/2020.
//

import CoreFoundationLib

struct NewTripInput {
    var countryCode: String
    var fromDate: Date
    var toDate: Date
    var selectedSegmentIndex: Int
}

protocol NoTripPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: NoTripViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func backButtonPressed()
    func searchButtonPressed()
    func menuPressed()
    func createTripWith(_ input: NewTripInput)
}

final class NoTripPresenter {
    weak var view: NoTripViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    private var coordinator: NoTripCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: NoTripCoordinatorProtocol.self)
    }
    
    private var coordinatorDelegate: NoTripCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: NoTripCoordinatorDelegate.self)
    }
    
    private var dataManager: PersonalAreaDataManagerProtocol {
        return self.dependenciesResolver.resolve(for: PersonalAreaDataManagerProtocol.self)
    }
    
    private var dataSource: TripsDataSourceProtocol {
        return self.dependenciesResolver.resolve()
    }
    
    private var stringLoader: StringLoader {
        return self.dependenciesResolver.resolve(for: StringLoader.self)
    }
    
    private var countries: [CountryEntity] {
        let configuration = self.dependenciesResolver.resolve(for: NoTripConfiguration.self)
        return configuration.countries
    }
    
    private var tripList: [TripEntity] {
        let configuration = self.dependenciesResolver.resolve(for: NoTripConfiguration.self)
        return configuration.trips
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension NoTripPresenter: NoTripPresenterProtocol {
    
    func viewDidLoad() {
        self.loadIsSearchEnabled()
        self.setCountriesList()
        self.trackScreen()
    }
    
    func viewWillAppear() {
        self.coordinator.attach()
    }

    func viewDidAppear() {
        self.checkFirstTimeVisited()
    }
    
    private func setCountriesList() {
        let countries = self.countries.compactMap(CountryDropdownModel.init)
        let reasons: [String] = [TripViewModel.reasonToString(.pleasure), TripViewModel.reasonToString(.business)]
        let countriesListViewModel = CountriesListViewModel(countries: countries, reasons: reasons)
        view?.setupViewModel(countriesListViewModel)
    }
    
    func createTripWith(_ input: NewTripInput) {
        guard let country = countries.filter({$0.code == input.countryCode}).first else { return }
        self.coordinatorDelegate.showLoading { [weak self, input] in
            let reason: TripReason = input.selectedSegmentIndex == 0 ? TripReason.pleasure : TripReason.business
            let tripEntity = TripEntity(country: country,
                                        fromDate: input.fromDate,
                                        toDate: input.toDate,
                                        currencies: country.currency,
                                        tripReason: reason)
            self?.trackEvent(.add, parameters: [.currency: country.currency, .travelType: reason.trackEvent])
            self?.dataSource.setNewTrip(tripEntity, { [weak self] completed in
                self?.coordinatorDelegate.hideLoading {
                    if completed {
                        self?.coordinator.gotoTripList()
                    } else {
                        // present error
                    }
                }
            })
        }
    }
    
    func menuPressed() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func backButtonPressed() {
        if tripList.isEmpty {
            self.coordinator.didSelectDismiss()
        } else {
            self.coordinator.goBackToTripList()
        }
    }
    
    func searchButtonPressed() {
        self.coordinatorDelegate.didSelectSearch()
    }
    
    func checkFirstTimeActions() {
        checkFirstTimeVisited()
    }
}

// MARK: - Private Methods

private extension NoTripPresenter {
    
    func checkFirstTimeVisited() {
        guard let userPref = dataManager.getUserPreference().userPrefEntity,
            !userPref.getTripModeVisited() else { return }
        self.saveVisit()
        self.view?.showToolTip(isInitialToolTip: true)
    }
    
    func saveVisit() {
        guard let entity = dataManager.getUserPreference().userPrefEntity else { return }
        entity.setTripModeVisited()
        dataManager.updateUserPreferencesValues(userPrefEntity: entity, onSuccess: nil, onError: nil)
    }
}

extension NoTripPresenter: GlobalSearchEnabledManagerProtocol {
    private func loadIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] (resp) in
            self?.view?.isSearchEnabled = resp
        }
    }
}

extension NoTripPresenter: AutomaticScreenActionTrackable {
    var trackerPage: TripPage {
        return TripPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
