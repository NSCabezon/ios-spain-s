import Foundation
import CoreFoundationLib
import UI

protocol TripDetailPresenterProtocol: AnyObject {
    var view: TripDetailViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectCardReportCall(_ phoneNumber: String)
    func didSelectFraudReportCall(_ phoneNumber: String)
    func didPressUnlockSignature()
    func didSelectSmartLock()
    func didSelectAtmsMap()
    func didSelectTip(_ offer: OfferEntity?)
    func didSwipeTips()
}

final class TripDetailPresenter {
    
    weak var view: TripDetailViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private let tripEntity: TripEntity
    
    private var dataSource: TripsDataSourceProtocol {
        return self.dependenciesResolver.resolve()
    }
    
    var tripViewModel: TripViewModel {
        return viewModelForEntity()
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.tripEntity = self.dependenciesResolver.resolve(for: TripDetailConfiguration.self).selectedTrip
    }
    
    // MARK: - privateMethods
    
    private var coordinatorDelegate: TripDetailCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: TripDetailCoordinatorDelegate.self)
    }
    
    private var securityAreaModuleCoordinator: SecurityAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: SecurityAreaCoordinatorDelegate.self)
    }
    
    private func viewModelForEntity() -> TripViewModel {
        let selectedTripEntity = dependenciesResolver.resolve(for: TripDetailConfiguration.self).selectedTrip
        return TripViewModel(from: selectedTripEntity, timeManager: dependenciesResolver.resolve(for: TimeManager.self))
    }
    
    private func selectedCountryEmbassy() -> EmbassyViewModel {
        let country = dependenciesResolver.resolve(for: TripDetailConfiguration.self).selectedCountry
        return EmbassyViewModel(country: country.name,
                                title: country.embassyTitle,
                                address: country.embassyAddress,
                                titleTelephone: country.embassyTitleTelephone,
                                telephone: country.embassyTelephone,
                                titleConsular: country.embassyTitleConsular,
                                telephoneConsularEmergency: country.embassyTelephoneConsularEmergency)
    }
    
    private func getEmergencyInfo() {
        dataSource.getEmergencyInfo { [weak self] result in
            let cardBlockNumbers = (result?.cardBlock.numbers ?? []).map { $0 }
            let fraudNumber = result?.fraude.numbers?.map { $0 }.first ?? ""
            guard let self = self else { return }
            self.view?.setEmbassy(self.selectedCountryEmbassy(),
                                  reportInfo: EmergencyReportViewModel(fraudReportNumber: fraudNumber,
                                                                       cardReportNumbers: cardBlockNumbers))
        }
    }
    
    private func getSafetyTips() {
        let baseUrlProvider = self.dependenciesResolver.resolve(for: BaseURLProvider.self)
        dataSource.getSafetyTips { [weak self] result in
            let viewModels = result?.securityTips?.map {
                return HelpCenterTipViewModel($0,
                                              baseUrl: baseUrlProvider.baseURL,
                                              descriptionBackground: UIColor.white)
            }
            self?.view?.setSecurityTips(viewModels ?? [])
        }
    }
}

extension TripDetailPresenter {
    private func setTripFaqsViewModels() {
        let fraudViewModel = TripFaqViewModel(iconName: "icnThief", titleKey: "yourTrips_label_fraud", descriptionKey: "yourTrips_text_fraud")
        let payViewModel = TripFaqViewModel(iconName: "icnDataphone", titleKey: "yourTrips_label_tips", descriptionKey: "yourTrips_text_tips")
        let expireViewModel = TripFaqViewModel(iconName: "icnCardOperations", titleKey: "yourTrips_label_expire", descriptionKey: "yourTrips_text_expire")
        let viewModels = [fraudViewModel, payViewModel, expireViewModel]
        self.view?.setFaqsViewModels(viewModels)
    }
}

extension TripDetailPresenter: TripDetailPresenterProtocol {
    func viewDidLoad() {
        self.view?.configureView(with: tripViewModel)
        self.setTripFaqsViewModels()
        self.getEmergencyInfo()
        self.getSafetyTips()
        self.view?.setSmartLock(countryName: self.tripEntity.country.name)
        self.trackScreen()
    }
    
    func didSelectDismiss() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func didSelectCardReportCall(_ phoneNumber: String) {
        self.coordinatorDelegate.didSelectCallPhoneNumber(phoneNumber)
        self.trackEvent(.robbery, parameters: [.tfno: phoneNumber])
    }
    
    func didSelectFraudReportCall(_ phoneNumber: String) {
        self.coordinatorDelegate.didSelectCallPhoneNumber(phoneNumber)
        self.trackEvent(.fraud, parameters: [.tfno: phoneNumber])
    }
    
    func didPressUnlockSignature() {
        self.coordinatorDelegate.unlockSignatureKeyDidPress()
        self.trackEvent(.multichannelSignal, parameters: [:])
    }
    
    func didSelectSmartLock() {
        self.coordinatorDelegate.goToSmartLock()
        self.trackEvent(.intelligentBlock, parameters: [:])
    }
    
    func didSelectTip(_ offer: OfferEntity?) {
        self.securityAreaModuleCoordinator.didSelectOffer(offer)
    }
    
    func didSelectAtmsMap() {
        self.coordinatorDelegate.goToAtms()
        self.trackEvent(.atm, parameters: [:])
    }
    
    func didSwipeTips() {
        self.trackEvent(.swipe, parameters: [:])
    }
}

extension TripDetailPresenter: AutomaticScreenActionTrackable {
    var trackerPage: TripDetailPage {
        TripDetailPage()
    }
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
