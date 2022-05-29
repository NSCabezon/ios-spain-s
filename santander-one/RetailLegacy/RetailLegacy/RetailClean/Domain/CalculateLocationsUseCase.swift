import CoreFoundationLib
import SANLegacyLibrary

class CalculateLocationsUseCase: UseCase<CalculateLocationsUseCaseInput, Void, StringErrorOutput> {
    
    private let pullOffersInterpreter: PullOffersInterpreter
    private let pullOffersConfigRepository: PullOffersConfigRepository
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository

    init(provider: BSANManagersProvider, pullOffersInterpreter: PullOffersInterpreter, pullOffersConfigRepository: PullOffersConfigRepository, appRepository: AppRepository) {
        self.provider = provider
        self.pullOffersInterpreter = pullOffersInterpreter
        self.pullOffersConfigRepository = pullOffersConfigRepository
        self.appRepository = appRepository
    }

    override func executeUseCase(requestValues: CalculateLocationsUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let user: String? = try {
            let isSessionEnabled = try appRepository.isSessionEnabled().getResponseData() ?? false
            if !isSessionEnabled {
                return "0"
            } else {
                guard let dto = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition()) else {
                    return nil
                }
                let gp = GlobalPosition.createFrom(dto: dto)
                return gp.userId
            }
        }()
        guard let userId = user else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        if let specificLocationsIds = requestValues.specificLocationsIds {
            pullOffersInterpreter.setCandidates(locations: filter(locationsIds: specificLocationsIds), userId: userId, reload: true)
        } else {
            pullOffersInterpreter.reset()
            let specific = PullOffersLocationsFactory().specificsLocations.map {
                return $0.stringTag
            }
            pullOffersInterpreter.setCandidates(locations: remove(locationsIds: specific), userId: userId, reload: false)
        }
        return UseCaseResponse.ok()
    }
    
    private func filter(locationsIds: [String]) -> [String: [String]] {
        var newLocations: [String: [String]] = [:]
        let locations = pullOffersConfigRepository.get()?.pullOffersConfig.locations ?? [:]
        for location in locations.keys where locationsIds.contains(location) {
            newLocations[location] = locations[location]
        }
        return newLocations
    }
    
    private func remove(locationsIds: [String]) -> [String: [String]] {
        var locations = pullOffersConfigRepository.get()?.pullOffersConfig.locations ?? [:]
        for location in locations.keys where locationsIds.contains(location) {
            locations[location] = nil
        }
        return locations
    }
}

struct CalculateLocationsUseCaseInput {
    
    let specificLocationsIds: [String]?
    
    init(specificLocationsIds: [String]? = nil) {
        self.specificLocationsIds = specificLocationsIds
    }
}
