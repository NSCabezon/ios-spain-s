//
//  CustomServiceInjector.swift
//  CoreTestData
//
//  Created by Juan Carlos López Robles on 2/24/22.
//

import Foundation

public protocol CustomServiceInjector {
    func inject(injector: MockDataInjector)
}
