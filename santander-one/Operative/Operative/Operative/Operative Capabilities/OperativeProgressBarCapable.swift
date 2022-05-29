//
//  OperativeProgressBarCapable.swift
//  Operative
//
//  Created by Jose Ignacio de Juan Díaz on 11/06/2021.
//

public protocol OperativeProgressBarCapable {
    var customStepsNumber: Int { get }
    var stepsCorrectionFactor: Int { get }
}

public extension OperativeProgressBarCapable {
    var stepsCorrectionFactor: Int {
        return 0
    }
}
