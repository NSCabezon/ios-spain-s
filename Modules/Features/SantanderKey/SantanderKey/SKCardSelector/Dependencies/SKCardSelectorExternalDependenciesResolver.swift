//
//  SKCardSelectorDependenciesResolver.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 24/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit

public protocol SKCardSelectorExternalDependenciesResolver {
    func resolve() -> UINavigationController
}
