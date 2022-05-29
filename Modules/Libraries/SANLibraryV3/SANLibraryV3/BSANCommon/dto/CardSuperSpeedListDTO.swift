public struct CardSuperSpeedListDTO: Codable {
    public var cards = [CardSuperSpeedDTO]()
    public var pagination: PaginationDTO?
}
