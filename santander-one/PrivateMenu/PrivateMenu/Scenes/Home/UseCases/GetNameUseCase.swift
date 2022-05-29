import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetNameUseCase {
    func fetchNameOrAlias() -> AnyPublisher<NameRepresentable, Never>
}

struct DefaultGetNameUseCase {
    private let globalPositionRepository: GlobalPositionDataRepository
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        globalPositionRepository = dependencies.resolve()
    }
}

extension DefaultGetNameUseCase: GetNameUseCase {
    func fetchNameOrAlias() -> AnyPublisher<NameRepresentable, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .map { globalPosition -> NameRepresentable in
                let userName = getName(from: globalPosition)
                let userAvailableName = getAvailableName(from: globalPosition)
                return Name(name: userName, availableName: userAvailableName)
            }
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetNameUseCase {
    func getName(from globalPositionDataRepresentable: GlobalPositionDataRepresentable) -> String {
        if let name = globalPositionDataRepresentable.clientNameWithoutSurname, !name.isEmpty {
            return name
        }
        return globalPositionDataRepresentable.clientName ?? ""
    }
    
    func getAvailableName(from globalPositionDataRepresentable: GlobalPositionDataRepresentable) -> String {
        guard let name = globalPositionDataRepresentable.clientNameWithoutSurname,
              let lastName = globalPositionDataRepresentable.clientFirstSurnameRepresentable,
              !name.isEmpty, !lastName.isEmpty else {
                  return globalPositionDataRepresentable.clientName ?? ""
              }
        return "\(name) \(lastName)"
    }
    
    struct Name: NameRepresentable {
        let name: String
        let availableName: String?
        let formatter = PersonNameComponentsFormatter()
        var initials: String? {
            if let availableName = availableName,
               let components = formatter.personNameComponents(from: availableName) {
                formatter.style = .abbreviated
                return(formatter.string(from: components))
            }
            return ""
        }
    }
}
