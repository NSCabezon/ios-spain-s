import CoreDomain
import OpenCombine

struct MockMenuRepository: MenuRepository {
    func loadNameOrAlias() -> AnyPublisher<NameRepresentable, Never> {
        struct MockName: NameRepresentable {
            var availableName: String? = "Antonio"
            var initials: String? = "A"
        }
        return Just(MockName()).eraseToAnyPublisher()
    }
    
    func fetchDigitalProfilePercentage() -> AnyPublisher<DigitalProfilePercentageRepresentable, Never> {
        struct MockDigitalProfile: DigitalProfilePercentageRepresentable {
            var percentage: Double = 10.0
            var notConfiguredItems: [DigitalProfileElemProtocol] = [MockDigitalProfileElem()]
            struct MockDigitalProfileElem: DigitalProfileElemProtocol {
                let identifier: String = "identifier"
                func value() -> Int {
                    0
                }
                func trackName() -> String {
                    ""
                }
                func desc() -> String {
                    ""
                }
                func title() -> String {
                    ""
                }
            }
        }
        return Just(MockDigitalProfile()).eraseToAnyPublisher()
    }
    
    func fetchSoapTokenCredential() -> AnyPublisher<String, Never> {
        return Just("tokenTest").eraseToAnyPublisher()
    }
}
