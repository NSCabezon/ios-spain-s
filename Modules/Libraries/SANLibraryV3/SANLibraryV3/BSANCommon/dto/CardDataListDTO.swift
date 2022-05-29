public struct CardDataListDTO: Codable {
    public let cardDataDTOs: [CardDataDTO]
    public let reposDatosTarjeta: ReposDatosTarjeta?

    public init(_ cardDataDTOs: [CardDataDTO], _ reposDatosTarjeta: ReposDatosTarjeta?) {
        self.cardDataDTOs = cardDataDTOs
        self.reposDatosTarjeta = reposDatosTarjeta
    }
}
