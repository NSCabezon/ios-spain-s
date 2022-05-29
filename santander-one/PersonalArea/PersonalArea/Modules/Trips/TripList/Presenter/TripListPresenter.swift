//
//  TripListPresenter.swift
//  PersonalArea
//
//  Created by alvola on 16/03/2020.
//
import CoreFoundationLib

protocol TripListPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: TripListViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func doSearch()
    func openMenu()
    func didSelectGoBack()
    func didSelectTrip(_ viewModel: TripViewModel)
    func didSelectRemoveTrip(_ viewModel: TripViewModel)
    func didSelectScheduleDate(_ viewModel: ForeignCurrencyVieModel)
    func didSelectAddNewTrip()
}

final class TripListPresenter {
    weak var view: TripListViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var countries: [CountryEntity] = []
    var trips: [TripEntity] = []
    var offers: [PullOfferLocation: OfferEntity] = [:]
    
    var coordinator: TripListCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: TripListCoordinatorProtocol.self)
    }
    
    var coordinatorDelegate: TripListCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: TripListCoordinatorDelegate.self)
    }
    
    private var timeManager: TimeManager {
        return self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private var dataSource: TripsDataSourceProtocol {
        return self.dependenciesResolver.resolve()
    }
    
    var locations: [PullOfferLocation] {
        [PullOfferLocation(stringTag: TripPullOffer.tripMode,
                           hasBanner: false,
                           pageForMetrics: trackerPage.page)]
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension TripListPresenter: TripListPresenterProtocol {
    func viewDidLoad() {
        self.loadIsSearchEnabled()
        self.view?.showLoadingView { [weak self] in
            self?.loadData()
        }
        self.trackScreen()
    }
    
    func viewWillAppear() {
        self.coordinator.attach()
    }
    
    private func loadData() {
        self.loadPullOffer { [weak self] in
            self?.loadTrips()
        }
    }
    
    private func loadTrips() {
        self.dataSource.getCountries({ [weak self] countries in
            self?.countries = countries
            self?.getCurrentTrips()
            }, failure: { [weak self] in
                self?.view?.hideLoadingView {
                    self?.coordinator.showDialogError {
                        self?.coordinator.didSelectDismiss()
                    }
                }
        })
    }
    
    func getCurrentTrips() {
        self.dataSource.getCurrentTrips(countries: countries,
                                         completion: { [weak self] trips in
                                            self?.trips = trips ?? []
                                            self?.view?.hideLoadingView {
                                                self?.handleTripsResponse()
                                            }
        })
    }
    
    func handleTripsResponse() {
        guard self.trips.isEmpty else { return self.setTrips() }
        self.coordinator.gotoAddNewTrips(countries: self.countries,
                                         trips: self.trips,
                                         replacing: true)
    }
    
    func setTrips() {
        let viewModels = self.trips.map { TripViewModel(from: $0, timeManager: timeManager) }
        self.view?.setViewModels(viewModels)
        self.setForeingCurrencyOffer()
        self.setAddNewTrip()
    }
    
    private func setAddNewTrip() {
        let maxNumberOfItemTrip = 2
        guard self.trips.count < maxNumberOfItemTrip else { return }
        self.view?.showAddNewTrip()
    }
    
    private func setForeingCurrencyOffer() {
        guard let offer = self.offers.location(key: TripPullOffer.tripMode)?.offer else { return }
        self.view?.setForeignCurrencyVieModel(ForeignCurrencyVieModel(offer: offer))
    }
    
    func openMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectGoBack() {
        self.coordinator.didSelectDismiss()
    }
    
    func doSearch() {
        self.coordinatorDelegate.didSelectSearch()
    }
    
    func didSelectTrip(_ viewModel: TripViewModel) {
        let entity = viewModel.tripEntity
        self.coordinator.didSelectTrip(entity, country: entity.country)
    }
    
    func didSelectScheduleDate(_ viewModel: ForeignCurrencyVieModel) {
        self.coordinatorDelegate.didSelectOffer(viewModel.offer)
    }

    func didSelectAddNewTrip() {
        self.coordinator.gotoAddNewTrips(countries: countries, trips: trips, replacing: false)
        self.trackEvent(.newTravel, parameters: [:])
    }
    
    func didSelectRemoveTrip(_ viewModel: TripViewModel ) {
        self.coordinator.showDialog(tripEntity: viewModel.tripEntity, accept: {[weak self] in
            self?.view?.showLoadingView(nil)
            self?.dataSource.removeTrip(viewModel.tripEntity) { [weak self] trips in
                self?.trips = trips ?? []
                self?.view?.hideLoadingView {
                    self?.handleTripsResponse()
                }
            }
        })
    }
}

extension TripListPresenter: AutomaticScreenActionTrackable {
    var trackerPage: TripPage {
        return TripPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension TripListPresenter: GlobalSearchEnabledManagerProtocol {
    private func loadIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] (resp) in
            self?.view?.isSearchEnabled = resp
        }
    }
}
