protocol SessionRepository {
    func startSession() -> RepositoryResponse<Void>
    func closeSession() -> RepositoryResponse<Void>
}
