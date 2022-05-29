import CoreFoundationLib

class GetSepaListUseCase: UseCase<Void, GetSepaListUseCaseOkOutput, StringErrorOutput> {
    private let sepaRepository: SepaInfoRepository

    init(sepaRepository: SepaInfoRepository) {
        self.sepaRepository = sepaRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSepaListUseCaseOkOutput, StringErrorOutput> {
        let sepaListDTO = sepaRepository.get()
        let sepaList = SepaInfoList(dto: sepaListDTO)
        return UseCaseResponse.ok(GetSepaListUseCaseOkOutput(sepaList: sepaList))
    }
}

struct GetSepaListUseCaseOkOutput {
    let sepaList: SepaInfoList
}
