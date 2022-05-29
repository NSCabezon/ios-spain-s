import CoreFoundationLib

final class ChangeCardAliasNameUseCaseErrorMock: UseCase<ChangeCardAliasNameInputUseCase, Void, StringErrorOutput> {
    var spyInput: ChangeCardAliasNameInputUseCase!
    public override func executeUseCase(requestValues: ChangeCardAliasNameInputUseCase) throws -> UseCaseResponse<Void, StringErrorOutput> {
        self.spyInput = requestValues
        return UseCaseResponse.error(StringErrorOutput(nil))
    }
}

final class ChangeCardAliasNameUseCaseMock: UseCase<ChangeCardAliasNameInputUseCase, Void, StringErrorOutput> {
    var spyInput: ChangeCardAliasNameInputUseCase!
    public override func executeUseCase(requestValues: ChangeCardAliasNameInputUseCase) throws -> UseCaseResponse<Void, StringErrorOutput> {
        self.spyInput = requestValues
        return .ok()
    }
}

extension ChangeCardAliasNameUseCaseErrorMock: ChangeCardAliasNameUseCaseProtocol { }
extension ChangeCardAliasNameUseCaseMock: ChangeCardAliasNameUseCaseProtocol { }
