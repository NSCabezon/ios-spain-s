public struct PensionContributionsListDTO: Codable {
    public var pensionContributions: [PensionContributionsDTO]?
    public var pensionInfoOperationDTO = PensionInfoOperationDTO()
    public var pagination: PaginationDTO?

    public init() {}
    
    public init(pensionContributions: [PensionContributionsDTO]?, pensionInfoOperationDTO: PensionInfoOperationDTO, pagination: PaginationDTO?) {
        self.pensionContributions = pensionContributions
        self.pensionInfoOperationDTO = pensionInfoOperationDTO
        self.pagination = pagination
    }

}
