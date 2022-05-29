//
//  StepInteractor.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/7/20.
//

import Foundation

final class StepInteractor {
    private var steps: [CardBoardingStep]
    private var position: Int = -1
    
    init(steps: [CardBoardingStep]) {
        self.steps = steps
    }
    
    func getCurrentPosition() -> Int {
        return self.position
    }
    
    func resetCurrentPosition() {
        self.position = -1
    }
    
    var count: Int {
        return self.steps.count
    }
    
    func popStep() {
        let index = position - 1
        guard index >= 0 else { return }
        self.position -= 1
    }
    
    func next() -> CardBoardingStep? {
        let index = position + 1
        guard index >= 0 else { return nil }
        guard index <= (self.steps.count) else { return  nil }
        self.position += 1
        return self.steps[position]
    }
}
