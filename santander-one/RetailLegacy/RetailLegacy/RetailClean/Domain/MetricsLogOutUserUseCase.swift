import CoreFoundationLib

class MetricsLogOutUserUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let tealiumRepository: TealiumRepository
    private let netInsightRepository: NetInsightRepository
    
    init(tealiumRepository: TealiumRepository, netInsightRepository: NetInsightRepository) {
        self.tealiumRepository = tealiumRepository
        self.netInsightRepository = netInsightRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        self.netInsightRepository.deleteUser()
        self.tealiumRepository.deleteUser()
        return UseCaseResponse.ok()
    }
}
