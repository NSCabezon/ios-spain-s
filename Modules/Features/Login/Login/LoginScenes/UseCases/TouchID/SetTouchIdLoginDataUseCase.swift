//
//  SetTouchIdLoginDataUseCase.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/23/20.
//

import CoreFoundationLib
import ESCommons

class SetTouchIdLoginDataUseCase: UseCase<SetTouchIdLoginDataInput, Void, SetTouchIdLoginDataErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let device: Device
    private let compilation: CompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.device = self.dependenciesResolver.resolve(for: Device.self)
        self.compilation = self.dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    override public func executeUseCase(requestValues: SetTouchIdLoginDataInput) throws -> UseCaseResponse<Void, SetTouchIdLoginDataErrorOutput> {
        
        if let deviceMagicPhrase = requestValues.deviceMagicPhrase, let touchIDLoginEnabled = requestValues.touchIDLoginEnabled {
            let touchIdData = TouchIdData(deviceMagicPhrase: deviceMagicPhrase,
                                          touchIDLoginEnabled: touchIDLoginEnabled,
                                          footprint: device.footprint)
            do {
                try KeychainWrapper().saveTouchIdData(touchIdData,
                                                    compilation: compilation)
                return UseCaseResponse.ok()
                
            } catch {
                return UseCaseResponse.error(SetTouchIdLoginDataErrorOutput(error.localizedDescription))
            }
        } else {
            do {
                try KeychainWrapper().deleteTouchIdData(compilation: compilation)
                return UseCaseResponse.ok()
                
            } catch {
                return UseCaseResponse.error(SetTouchIdLoginDataErrorOutput(error.localizedDescription))
            }
        }
    }
}

struct SetTouchIdLoginDataInput {
    let deviceMagicPhrase: String?
    let touchIDLoginEnabled: Bool?
}

class SetTouchIdLoginDataErrorOutput: StringErrorOutput {}
