import CoreFoundationLib
import SANLegacyLibrary
import Operative

class GetOpinatorParametersValuesUseCase: UseCase<GetOpinatorParametersValuesUseCaseInput, GetOpinatorParametersValuesUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }

    override func executeUseCase(requestValues: GetOpinatorParametersValuesUseCaseInput) throws -> UseCaseResponse<GetOpinatorParametersValuesUseCaseOkOutput, StringErrorOutput> {
        let webViewTimer = appConfigRepository.getString("timerLoadingTips") ?? "0"
        let values = try requestValues.parameters.reduce([String: String](), { result, parameter in
            var new = result
            guard let value = try valueFor(parameter: parameter) else {
                return new
            }
            new[parameter.key] = value
            return new
        })
        guard requestValues.parameters.count == values.count else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(GetOpinatorParametersValuesUseCaseOkOutput(values: values, webViewTimer: Int(webViewTimer)))
    }
    
    private func valueFor(parameter: DomainOpinatorParameter) throws -> String? {
        switch parameter {
        case .userId:
            do {
                let userIdResponse = try provider.getBsanPGManager().getGlobalPosition()
                guard userIdResponse.isSuccess(), let globalPositionDTO = try userIdResponse.getResponseData() else {
                    return nil
                }
                return GlobalPosition.createFrom(dto: globalPositionDTO).userId
            } catch {
                return ""
            }
        case .appVersion:
            return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        case .language:
            return dependenciesResolver.resolve(for: StringLoader.self).getCurrentLanguage().languageType.languageCode as? String
        case .browser:
            return "Safari"
        case .devicemodel:
            return UIDevice.current.humanReadableDeviceModel
        case .os:
            return "iOS"
        }
    }
}

struct GetOpinatorParametersValuesUseCaseInput {
    let parameters: [DomainOpinatorParameter]
}

struct GetOpinatorParametersValuesUseCaseOkOutput {
    let values: [String: String]
    let webViewTimer: Int?
}
