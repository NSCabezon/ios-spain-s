//
//  GetTouchIdLoginDataUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/9/20.
//

import Foundation
import CoreFoundationLib
import ESCommons

class GetTouchIdLoginDataUseCase: UseCase<Void, GetTouchIdLoginDataOkOutput, GetTouchIdLoginDataErrorOutput> {
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetTouchIdLoginDataOkOutput, GetTouchIdLoginDataErrorOutput> {
        guard let localAuthData = KeychainWrapper().touchIdData(compilation: compilation) else {
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
