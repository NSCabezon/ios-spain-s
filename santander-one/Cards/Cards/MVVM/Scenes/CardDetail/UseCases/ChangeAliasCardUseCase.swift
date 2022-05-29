import Foundation
import OpenCombine
import CoreDomain

public protocol ChangeAliasCardUseCase {
    func fetchChangeAliasCard(card: CardRepresentable, newAlias: String) -> AnyPublisher<Void, Error>
}

struct DefaultChangeAliasCardUseCase: ChangeAliasCardUseCase {
    private let repository: CardRepository
    
    init(dependencies: CardDetailDependenciesResolver) {
        repository = dependencies.external.resolve()
    }
}

extension DefaultChangeAliasCardUseCase {
    func fetchChangeAliasCard(card: CardRepresentable, newAlias: String) -> AnyPublisher<Void, Error> {
        return repository
            .changeAliasCard(card: card, newAlias: newAlias)
            .eraseToAnyPublisher()
    }
}
