import OpenCombine
import CoreDomain
import Transfer

struct GetReactiveContactsUseCaseMock: GetReactiveContactsUseCase {
    private var sucess: [PayeeRepresentable]?
    private var error: Error?
    
    init(sucess: [PayeeRepresentable]) {
        self.sucess = sucess
    }
    
    init(error: Error) {
        self.error = error
    }
    
    func fetchContacts() -> AnyPublisher<[PayeeRepresentable], Error> {
        if let sucess = sucess {
            return Just(sucess)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        if let error = error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        return Empty()
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
