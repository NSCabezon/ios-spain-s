public protocol BSANSignBasicOperationManager {
    func getSignaturePattern() throws -> BSANResponse<GetSignPatternDTO>
    func startSignPattern(_ pattern: String, instaID: String) throws -> BSANResponse<SignBasicOperationDTO>
    func validateSignPattern(_ input: SignValidationInputParams) throws -> BSANResponse<SignBasicOperationDTO>
    func getContractCmc() throws -> String
}
