//
//  ShoppingMapViewModel.swift
//  Cards
//
//  Created by Hernán Villamil on 21/2/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

typealias DateFiler = (startDate: Date, endDate: Date)
typealias DatedLoactionInput = (configuration: CardMapConfiguration, filter: DateFiler)
typealias LocationsPublisherOutput = ((locations: [CardMovementLocationRepresentable], configuration: CardMapConfiguration))

enum CardShoppingMapState: State {
    case idle
    case presentLoader(Bool)
    case loadMultipleLocations(CardMapConfiguration)
    case loadDatedLocations(DatedLoactionInput)
    case localizedTextLoaded(LocalizedStylableText)
    case locationsLoaded([CardMapItemRepresentable])
}

final class CardShoppingMapViewModel: DataBindable {
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: CardShoppingMapDependenciesResolver
    private var getMultipleLocations: GetMultipleCardMovementLocationsForShoppingMapUseCase {
        dependencies.external.resolve()
    }
    private var getDatedLocations: GetDatedCardMovementsLocationsForShoppingMapUseCase {
        dependencies.external.resolve()
    }
    private var coordinator: CardShoppingMapCoordinator {
        dependencies.resolve()
    }
    var dataBinding: DataBinding {
        dependencies.resolve()
    }
    @BindingOptional private var configurationData: CardMapConfiguration?
    private let stateSubject = CurrentValueSubject<CardShoppingMapState, Never>(.idle)
    var state: AnyPublisher<CardShoppingMapState, Never>
    
    init(dependencies: CardShoppingMapDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        subscribeMultipleLocations()
        subscribeDatedLocations()
        setLocalizedText()
        trackEvent(.map, parameters: [:])
    }
    
    func didSelectClose() {
        coordinator.dismiss()
    }
    
    func didSelectAcceptError() {
        coordinator.dismiss()
    }
}

private extension CardShoppingMapViewModel {
    func setLocalizedText() {
        guard let configuration = configurationData else { return }
        let text: LocalizedStylableText
        switch configuration.type {
        case .one:
            text = localized("shoppingMap_label_movements_one")
        case .multiple:
            text = localized("shoppingMap_label_movements_other", [StringPlaceholder(StringPlaceholder.Placeholder.number, "24")])
        case .date:
            text = localized("shoppingMap_label_movements_other", [StringPlaceholder(StringPlaceholder.Placeholder.number, "24")])
        }
        stateSubject.send(.localizedTextLoaded(text))
        getLocationsForConfiguration(configuration)
    }
    
    func getLocationsForConfiguration(_ configuration: CardMapConfiguration) {
        switch configuration.type {
        case .one(let location):
            stateSubject.send(.locationsLoaded([location]))
        case .multiple:
            stateSubject.send(.presentLoader(true))
            stateSubject.send(.loadMultipleLocations(configuration))
        case .date(let startDate, let endDate):
            let filter = DateFiler(startDate: startDate, endDate: endDate)
            let input = DatedLoactionInput(configuration: configuration, filter: filter)
            stateSubject.send(.presentLoader(true))
            stateSubject.send(.loadDatedLocations(input))
        }
    }
    
    func setMapWithLocations(_ locations: [CardMovementLocationRepresentable], configuration: CardMapConfiguration) {
        let output = getLocationsOutput(locations, alias: configuration.card.alias)
        let text = localized("shoppingMap_label_movements_other",
                             [StringPlaceholder(StringPlaceholder.Placeholder.number, "\(locations.count)")])
        stateSubject.send(.localizedTextLoaded(text))
        stateSubject.send(.locationsLoaded(output))
    }
    
    func getLocationsOutput(_ locations: [CardMovementLocationRepresentable], alias: String?) -> [CardMapItemRepresentable] {
        let totalValues: Decimal = locations.reduce(0) {
            return $0 + ($1.amountRepresentable?.value ?? 0)
        }
        var output = [CardMapItemRepresentable]()
        locations.forEach { location in
            if let latitude = location.latitude,
               let longitude = location.longitude,
               let amountRepresentable = location.amountRepresentable {
                let amount = AmountEntity(amountRepresentable)
                let item = CardMapItem(date: location.date,
                                                name: location.concept,
                                                alias: alias,
                                                amount: amount,
                                                address: location.address,
                                                postalCode: location.postalCode,
                                                location: location.location,
                                                latitude: latitude,
                                                longitude: longitude,
                                                amountValue: location.amountRepresentable?.value,
                                                totalValues: totalValues)
                
                output.append(item)
            }
        }
        return output
    }
}

// MARK: Subscriptions
private extension CardShoppingMapViewModel {
    func subscribeMultipleLocations() {
        multipleLocationsPublisher()
            .sink { [unowned self] result in
                self.setMapWithLocations(result.locations, configuration: result.configuration)
            }.store(in: &subscriptions)
    }
    
    func subscribeDatedLocations() {
        datedLocationsPublisher()
            .sink { [unowned self] result in
                self.setMapWithLocations(result.locations, configuration: result.configuration)
            }.store(in: &subscriptions)
    }
}

// MARK: Publishers
private extension CardShoppingMapViewModel {
    func multipleLocationsPublisher() -> AnyPublisher<LocationsPublisherOutput, Never> {
        return stateSubject
            .case(CardShoppingMapState.loadMultipleLocations)
            .flatMap { [unowned self] configuration in
                self.getMultipleLocations
                    .fetchLocationsForShoppingMap(card: configuration.card)
                    .map({ LocationsPublisherOutput(locations: $0,
                                                    configuration: configuration) })
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
    
    func datedLocationsPublisher() -> AnyPublisher<LocationsPublisherOutput, Never> {
        return stateSubject
            .case(CardShoppingMapState.loadDatedLocations)
            .flatMap { [unowned self] input in
                self.getDatedLocations
                    .fetchLocationsForShoppingMap(card: input.configuration.card,
                                                  startDate: input.filter.startDate,
                                                  endDate: input.filter.endDate)
                    .map({ LocationsPublisherOutput(locations: $0,
                                                    configuration: input.configuration) })
            }.receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}

// MARK: Analytics
extension CardShoppingMapViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: CardsHomePage {
        CardsHomePage()
    }
}
