//
//  MockPreSetupCapability.swift
//  UI_ExampleTests
//
//  Created by José Carlos Estela Anguita on 20/1/22.
//

import Foundation
import Operative
import OpenCombine
import UI

struct MockPreSetupCapability<Operative: ReactiveOperative>: WillStartCapability {
    
    var spyPreSetupSubject = CurrentValueSubject<Bool, Never>(false)
    let operative: Operative
    var result: ConditionState = .success
    
    var willStartPublisher: AnyPublisher<ConditionState, Never> {
        return Just(result)
            .handleEvents(receiveSubscription: { _ in
                self.spyPreSetupSubject.send(true)
            })
            .eraseToAnyPublisher()
    }
}
