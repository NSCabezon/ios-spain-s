import CoreFoundationLib
import OpenCombine
import Transfer

struct GetOneFaqsUseCaseMock: GetOneFaqsUseCase {
    func fetchFaqs(type: FaqsType) -> AnyPublisher<OneFooterData, Never> {
        return Just(
            OneFooterData(
                faqs: [],
                tips: [],
                virtualAssistant: false
            )
        )
            .eraseToAnyPublisher()
    }
}
