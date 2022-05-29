import Foundation
import CoreFoundationLib

class GetTouchIdLoginDataUseCase: LocalAuthLoginDataUseCase<Void, GetTouchIdLoginDataOkOutput, GetTouchIdLoginDataErrorOutput> {
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetTouchIdLoginDataOkOutput, GetTouchIdLoginDataErrorOutput> {
        guard let localAuthData = getLocalAuthData(requestValues: requestValues) else {
            return UseCaseResponse.error(GetTouchIdLoginDataErrorOutput(nil))
        }
        
        return UseCaseResponse.ok(GetTouchIdLoginDataOkOutput(touchIdData: localAuthData))
    }
}

struct GetTouchIdLoginDataOkOutput {
    let touchIdData: TouchIdData
}

class GetTouchIdLoginDataErrorOutput: StringErrorOutput {
}
