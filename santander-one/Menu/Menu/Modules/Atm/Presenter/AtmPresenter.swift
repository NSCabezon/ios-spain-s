//
//  AtmPresenter.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 31/08/2020.
//

import Foundation
import CoreFoundationLib
import UI
import CoreDomain

enum AtmLocations: String, CaseIterable {
    case report = "Z_ATM_REPORT"
    case officeAppointment = "ATM_OFFICE_APPOINTMENT"
}

protocol AtmPresenterProtocol: AnyObject {
    var view: AtmViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didSelectedGetMoneyWithCode()
    func didSelectedCardLimitManagement()
    func didSelectedReportAtmBug(_ viewModel: OfferEntityViewModel?)
    func didSelectSearchAtm()
    func didSelectTip(_ viewModel: AtmTipViewModel)
    func didSelectSeeAllTips()
    func formatDate(_ date: Date) -> LocalizedStylableText
    func didSelectAtmMachineAddress(_ viewModel: AtmViewModel)
    func didSelectedOfficeAppointment(_ viewModel: OfferEntityViewModel?)
    func didSelectedBanner(_ viewModel: OfferBannerViewModel?)
}

class AtmPresenter {
    weak var view: AtmViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private let locations: [PullOfferLocation] = PullOffersLocationsFactoryEntity().atm
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    private var atmTipViewModels: [AtmTipViewModel]?
    private var isEnabledGetMoneyWithCode: Bool?
    private var isEnabledCardLimitManagement: Bool?
    private var isEnabledNearestAtms: Bool?

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
   
    var coordinatorDelegate: AtmCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: AtmCoordinatorDelegate.self)
    }
    
    var coordinator: AtmCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: AtmCoordinatorProtocol.self)
    }
    
    var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var getPullOffersCandidatesUseCase: GetOffersCandidatesUseCase {
        self.dependenciesResolver.resolve()
    }
    
    var atmUseCase: GetAtmUseCase {
        return self.dependenciesResolver.resolve(for: GetAtmUseCase.self)
    }
    
    lazy var accountMovementSuperUseCase: GetAtmMovemetsSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetAtmMovemetsSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    private var getNearestAtmUseCase: GetNearestAtmsUseCase {
        return GetNearestAtmsUseCase(dependenciesResolver: self.dependenciesResolver)
    }
    
    private var locationManager: LocationPermission {
        return self.dependenciesResolver.resolve(for: LocationPermission.self)
    }
}

private extension AtmPresenter {
    func loadOffers(completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: getPullOffersCandidatesUseCase.setRequestValues(requestValues: GetOffersCandidatesUseCaseInput(locations: self.locations)),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                self?.pullOfferCandidates = result.pullOfferCandidates
                completion()
            }
        )
    }
    
    func showLocation() {
        guard self.pullOfferCandidates != nil else {
            return
        }
        AtmLocations.allCases.forEach {
            guard let offerEntity = self.pullOfferCandidates?.location(key: $0.rawValue)?.offer, let location = AtmLocations(rawValue: $0.rawValue) else { return }
            let viewModel = OfferEntityViewModel(entity: offerEntity)
            self.view?.setOfferBannerForLocation(location, viewModel: viewModel)
        }
    }

    func loadAtm(completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: atmUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.atmTipViewModels = result.atmTips?.map {
                    return AtmTipViewModel($0, baseUrl: self?.baseUrlProvider.baseURL)
                }
                self?.isEnabledGetMoneyWithCode = result.isEnabledGetMoneyWithCode
                self?.isEnabledCardLimitManagement = result.isEnabledCardLimitManagement
                self?.isEnabledNearestAtms = result.isEnabledNearestAtms
                completion()
            }, onError: { _ in
                completion()
        })
    }
    
    func loadMovements() {
        self.accountMovementSuperUseCase.execute()
    }
    
    func loadingFinished() {
        self.loadOffers {
            if self.isEnabledCardLimitManagement == true {
                self.view?.showCardLimitManagemetView()
            }
            self.showLocation()
            self.view?.showTips(self.atmTipViewModels)
            self.view?.dismissLoading(completion: nil)
        }
    }
}

extension AtmPresenter: AtmPresenterProtocol {
    func formatDate(_ date: Date) -> LocalizedStylableText {
        var dateString =  dependenciesResolver.resolve(for: TimeManager.self)
            .toStringFromCurrentLocale(date: date,
                                       outputFormat: .d_MMM)?.uppercased() ?? ""
        let weekDayString = dependenciesResolver.resolve(for: TimeManager.self)
            .toStringFromCurrentLocale(date: date,
                                       outputFormat: .eeee)?.camelCasedString ?? ""
        dateString.append(" | \(weekDayString)")
        if date.isDayInToday() {
            return localized("product_label_todayTransaction", [StringPlaceholder(.date, dateString)])
        } else {
            return LocalizedStylableText(text: dateString, styles: nil)
        }
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func didSelectSearch() {
        self.coordinatorDelegate.didSelectSearch()
    }
    
    func didSelectedGetMoneyWithCode() {
        self.coordinatorDelegate.didSelectedGetMoneyWithCode()
    }
    
    func didSelectedCardLimitManagement() {
        self.coordinatorDelegate.didSelectedCardLimitManagement()
    }
    
    func didSelectedReportAtmBug(_ viewModel: OfferEntityViewModel?) {
        self.coordinatorDelegate.didSelectOffer(viewModel?.offer)
    }
    
    func didSelectedOfficeAppointment(_ viewModel: OfferEntityViewModel?) {
        self.coordinatorDelegate.didSelectOffer(viewModel?.offer)
    }
    
    func didSelectSearchAtm() {
        self.coordinatorDelegate.didSelectSearchAtm()
    }
    
    func viewDidLoad() {
        self.trackScreen()
        self.loadAtm { [weak self] in
            self?.checkIfIsNearestAtmsEnabled { isNearestAtmsEnabled in
                self?.loadViewData(isNearestAtmsEnabled)
            }
        }
    }
    
    func didSelectTip(_ viewModel: AtmTipViewModel) {
        self.coordinatorDelegate.didSelectOffer(viewModel.entity.offer)
    }
    
    func didSelectSeeAllTips() {
        self.coordinatorDelegate.goToHomeTips()
    }
    
    func didSelectedBanner(_ viewModel: OfferBannerViewModel?) {
        guard let offer = viewModel?.offer else {
            return
        }
        self.coordinatorDelegate.didSelectOffer(offer)
    }
}

private extension AtmPresenter {
    func loadViewData(_ isNearestAtmsEnabled: Bool) {
        self.view?.showLoading {
            self.view?.showSearchAtmView()
            self.loadNearestAtms(isNearestAtmsEnabled, completion: {
                self.loadMovements()
                guard self.isEnabledGetMoneyWithCode == true else {
                    return
                }
                self.loadOffers {
                    self.view?.showGetMoneyWithCodeView()
                    self.checkBannerLocation()
                }
            })
        }
    }
    func checkIfIsNearestAtmsEnabled(completion: @escaping (Bool) -> Void) {
        if self.isEnabledNearestAtms == true {
            if self.locationManager.isLocationAccessEnabled() {
                completion(true)
            } else {
                self.locationManager.setLocationPermissionsIfNotAsked {
                    completion(self.locationManager.isLocationAccessEnabled())
                }
            }
        } else {
            completion(false)
        }
    }
    
    func loadNearestAtms(_ isNearestAtmsEnabled: Bool, completion: @escaping () -> Void) {
        if isNearestAtmsEnabled {
            self.locationManager.getCurrentLocation { latitude, longitude in
                guard let latitude = latitude, let longitude = longitude else {
                    completion()
                    return
                }
                let input = GetNearestAtmsUseCaseInput(latitude: latitude, longitude: longitude)
                self.getNearestAtmsUseCase(input: input, completion: {
                    completion()
                })
            }
        } else {
            completion()
        }
    }
    
    func getNearestAtmsUseCase(input: GetNearestAtmsUseCaseInput, completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: self.getNearestAtmUseCase.setRequestValues(requestValues: input),
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { result in
                let viewModels = result.nearetsAtms.map({ AtmViewModel($0) })
                let viewModel = NearAtmViewModel(
                    atmViewModels: viewModels,
                    isEnrichedAtmServiceEnabled: result.isEnrichedATMServiceAvailable
                )
                self.view?.showAtmCashierView(viewModel)
                completion()
            },
            onError: { _ in
                completion()
        })
    }
    
    func checkBannerLocation() {
        guard let offer = self.pullOfferCandidates?.location(key: AccountsPullOffers.customizeAtmOptions) else {
            // Update without banner
            self.view?.setOfferBannerLocation(nil)
            return
        }
        let viewModel = OfferBannerViewModel(entity: offer.offer)
        self.view?.setOfferBannerLocation(viewModel)
    }
}

extension AtmPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: AtmPage {
        return AtmPage()
    }
}

private typealias MovementsByDate = (date: Date, viewModels: [AtmMovementViewModel])

extension AtmPresenter: GetAtmMovementsSuperUseCaseDelegate {
    func didFinishMovementsSuccessfully(with accountMovements: [AccountEntity: [AccountMovementRepresentable]]) {
        let viewModels = self.movementsViewModels(for: accountMovements)
        guard !viewModels.isEmpty else { return self.loadingFinished() }
        let movementsByDate = viewModels.reduce([Date: [AtmMovementViewModel]]()) { dictionary, viewModel in
            var dict = dictionary
            let day = viewModel.date.startOfDay()
            dict[day] = (dict[day] ?? []) + [viewModel]
            return dict
        }
        let sortedDictionary = movementsByDate
            .map { MovementsByDate(date: $0.key, viewModels: $0.value) }
            .sorted { $0.date > $1.date }
        self.view?.showLastWithdrawal(sortedDictionary)
        self.loadingFinished()
    }
    
    func didFinishMovementsWithError() {
        self.loadingFinished()
    }
    
    func movementsViewModels(for movements: [AccountEntity: [AccountMovementRepresentable]]) -> [AtmMovementViewModel] {
        let viewModels = movements.flatMap { element in
            self.movementViewModel(for: element.key, movements: element.value)
        }.sorted(by: {$0.date > $1.date}).prefix(3)
        return Array(viewModels)
    }
    
    func movementViewModel(for account: AccountEntity, movements: [AccountMovementRepresentable]) -> [AtmMovementViewModel] {
        return movements.map { AtmMovementViewModel($0, account: account) }
    }
    
    func didSelectAtmMachineAddress(_ viewModel: AtmViewModel) {
        self.locationManager.getCurrentLocation { (lat, long) in
            guard let latitude = lat, let longitude = long else { return }
            let mapUrl = URLMapBuilder()
                .fromLocation
                    .latitude(latitude)
                    .longitude(longitude)
                .toLocation
                    .latitude(viewModel.atmEntity.latitude)
                    .longitude(viewModel.atmEntity.longitude)
                .build()
            guard let url = mapUrl else { return }
            self.openUrl(url)
        }
    }
}

extension AtmPresenter: OpenUrlCapable {}
