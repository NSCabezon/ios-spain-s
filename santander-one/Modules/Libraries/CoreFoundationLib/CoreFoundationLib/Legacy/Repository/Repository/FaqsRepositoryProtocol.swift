

public protocol FaqsRepositoryProtocol {
    func getFaqsList() -> FaqsListDTO?
    func getFaqsList(_ type: FaqsType) -> [FaqDTO]
}
