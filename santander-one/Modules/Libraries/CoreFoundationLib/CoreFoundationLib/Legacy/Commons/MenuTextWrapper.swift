
public protocol MenuTextGetProtocol {
    func get(completion: @escaping ([MenuTextModel: String]) -> Void)
}

public protocol MenuTextWrapperProtocol: MenuTextGetProtocol {
    var dependenciesResolver: DependenciesResolver { get }
}

public extension MenuTextWrapperProtocol {
    func get(completion: @escaping ([MenuTextModel: String]) -> Void) {
        MainThreadUseCaseWrapper(with: MenuTextUseCase(appConfigRepository: self.dependenciesResolver.resolve()), onSuccess: { response in
            completion(response.texts)
        }, onError: { _ in
            completion([:])
        })
    }
}

public class MenuTextUseCase: UseCase<Void, MenuTextUseCaseOutput, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    public init(appConfigRepository: AppConfigRepositoryProtocol) {
        self.appConfigRepository = appConfigRepository
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<MenuTextUseCaseOutput, StringErrorOutput> {
        var texts: [MenuTextModel: String] = [:]
        for item in MenuTextModel.allCases {
            texts[item] = self.appConfigRepository.getString(item.rawValue)
        }
        return UseCaseResponse.ok(MenuTextUseCaseOutput(texts: texts))
    }
}

public struct MenuTextUseCaseOutput {
    public let texts: [MenuTextModel: String]
}
