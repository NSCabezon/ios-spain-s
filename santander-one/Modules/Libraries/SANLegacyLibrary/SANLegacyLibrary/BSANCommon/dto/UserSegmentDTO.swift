public struct UserSegmentDTO: Codable {
    public var bdpSegment: SegmentDTO?
    public var commercialSegment: SegmentDTO?
    public var indCollectiveS: Bool?
    public var indColectivoRenunAcc: Bool?
    public var indColectivoCarenciaOGracia: Bool?
    public var indCollectiveSFreelance: Bool?
    public var indCollectiveSCompanies: Bool?
    public var colectivoJuzgados: Bool?
    public var colectivo123Smart: Bool?
    public var colectivo123SmartFree: Bool?
	public var colectivoAutonomoPrem: Bool?
	public var colectivoAutonomoFree: Bool?

    public init () {}
}
