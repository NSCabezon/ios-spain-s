import CoreFoundationLib

class GetAllComingFeaturesUseCase: UseCase<Void, GetAllComingFeaturesUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAllComingFeaturesUseCaseOkOutput, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let globalPosition: GlobalPositionRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let userPrefDTO = appRepositoryProtocol.getUserPreferences(userId: globalPosition.userId ?? "")
        let alreadyVotedFeatures: [String] = userPrefDTO.comingFeaturesVotedIds
        let comingFeaturesRepository = dependenciesResolver.resolve(for: ComingFeaturesRepositoryProtocol.self)
        guard let urlBase = try appRepositoryProtocol.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else {
            return .ok(GetAllComingFeaturesUseCaseOkOutput(comingFeatures: [], implementedFeatures: []))
        }
        let languageType = appRepositoryProtocol.getCurrentLanguage()
        comingFeaturesRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        guard let featuresResponse = comingFeaturesRepository.getFeatures() else {
            return .ok(GetAllComingFeaturesUseCaseOkOutput(comingFeatures: [], implementedFeatures: []))
        }
        let comingFeatureDTOs = featuresResponse.comingFeatures
        let implementedFeatureDTOs = featuresResponse.alreadyImplementedFeatures
        let comingFeatures = comingFeatureDTOs.map { feature in
            ComingFeatureEntity(dto: feature, isVoted: alreadyVotedFeatures.contains(feature.identifier))
        }
        let implementedFeatures = implementedFeatureDTOs.map(ImplementedFeatureEntity.init)
        return .ok(GetAllComingFeaturesUseCaseOkOutput(comingFeatures: comingFeatures, implementedFeatures: implementedFeatures))
    }
}

struct GetAllComingFeaturesUseCaseOkOutput {
    let comingFeatures: [ComingFeatureEntity]
    let implementedFeatures: [ImplementedFeatureEntity]
}
