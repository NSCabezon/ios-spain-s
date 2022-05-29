//
//  SetTouchIdLoginDataUseCase.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/23/20.
//

import CoreFoundationLib
import ESCommons

final class SetTouchIdLoginDataUseCase: UseCase<SetTouchIdLoginDataInput, Void, StringErrorOutput> {
    private let device: Device
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.device = dependenciesResolver.resolve(for: Device.self)
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override public func executeUseCase(requestValues: SetTouchIdLoginDataInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        if let deviceMagicPhrase = requestValues.deviceMagicPhrase, let touchIDLoginEnabled = requestValues.touchIDLoginEnabled {
            let touchIdData = TouchIdData(deviceMagicPhrase: deviceMagicPhrase,
                                          touchIDLoginEnabled: touchIDLoginEnabled,
                                          footprint: device.footprint)
            do {
                try KeychainWrapper().saveTouchIdData(touchIdData, compilation: compilation)
                return UseCaseResponse.ok()
            } catch {
                return UseCaseResponse.error(StringErrorOutput(error.localizedDescription))
            }
        } else {
            do {
                try KeychainWrapper().deleteTouchIdData(compilation: compilation)
                return UseCaseResponse.ok()
            } catch {
                return UseCaseResponse.error(StringErrorOutput(error.localizedDescription))
            }
        }
    }
}

struct SetTouchIdLoginDataInput {
    let deviceMagicPhrase: String?
    let touchIDLoginEnabled: Bool?
}
