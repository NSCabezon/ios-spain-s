
public protocol DigitalProfileItemsProviderProtocol {
    func getItems() -> (configuredItems: [DigitalProfileElemProtocol], notConfiguredItems: [DigitalProfileElemProtocol])
    func didSelect(item: DigitalProfileElemProtocol)
}
