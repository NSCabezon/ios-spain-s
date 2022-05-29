//
//  OnboardingServiceInjector.swift
//  Commons
//
//  Created by José Norberto Hidalgo Romero on 24/12/21.
//

import CoreTestData
import QuickSetup

public final class OnboardingServiceInjector: CustomServiceInjector {
    public init() {}
    public func inject(injector: MockDataInjector) {
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
    }
}
