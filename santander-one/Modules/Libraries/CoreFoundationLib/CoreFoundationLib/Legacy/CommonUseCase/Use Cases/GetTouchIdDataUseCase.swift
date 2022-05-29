//
//  GetTouchIdLoginDataUseCase.swift
//  CommonUseCase
//
//  Created by Rubén Márquez Fernández on 25/5/21.
//

import Foundation

public class GetTouchIdDataUseCase: UseCase<Void, GetTouchIdLoginDataOkOutput, GetTouchIdLoginDataErrorOutput> {
    
    private let compilation: CompilationProtocol
    private var touchIdData: TouchIdData? {
        return KeychainWrapper().touchIdData(compilation: compilation)
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetTouchIdLoginDataOkOutput, GetTouchIdLoginDataErrorOutput> {
        guard let localAuthData = self.touchIdData else {
            return UseCaseResponse.error(GetTouchIdLoginDataErrorOutput(nil))
        }
        return UseCaseResponse.ok(GetTouchIdLoginDataOkOutput(touchIdData: localAuthData))
    }
}

public struct GetTouchIdLoginDataOkOutput {
    public let touchIdData: TouchIdData
}

public class GetTouchIdLoginDataErrorOutput: StringErrorOutput {
}
