import CoreFoundationLib
import OpenCombine
import Transfer

struct GetSendMoneyActionsUseCaseMock: GetSendMoneyActionsUseCase {
    private var sucess: [SendMoneyActionType]
    
    init(sucess: [SendMoneyActionType]) {
        self.sucess = sucess
    }
    
    func fetchSendMoneyActions(_ locations: [PullOfferLocation]) -> AnyPublisher<[SendMoneyActionType], Never> {
        return Just(sucess)
            .eraseToAnyPublisher()
    }
}
