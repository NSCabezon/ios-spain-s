import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class LoadOTPPushDeviceUseCase: UseCase<LoadOTPPushDeviceUseCaseInput, Void, StringErrorOutput> {
    
    private let bsanManagerProvider: BSANManagersProvider
    
    init(bsanManagerProvider: BSANManagersProvider) {
        self.bsanManagerProvider = bsanManagerProvider
    }
    
    override func executeUseCase(requestValues: LoadOTPPushDeviceUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        _ = try? bsanManagerProvider.getBsanOTPPushManager().requestDevice()
        return .ok()
    }
}

struct LoadOTPPushDeviceUseCaseInput {
    let appId: String
}
