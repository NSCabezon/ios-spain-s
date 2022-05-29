import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetSavingProductComplementaryDataUseCase {
    func fechComplementaryDataPublisher() -> AnyPublisher<[String: [DetailTitleLabelType]], Never>
}
