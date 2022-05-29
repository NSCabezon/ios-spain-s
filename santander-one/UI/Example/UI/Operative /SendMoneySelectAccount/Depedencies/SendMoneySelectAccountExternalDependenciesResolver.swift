//
//  SendMoneySelectAccountExternalDependenciesResolver.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 5/1/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import UIKit

public protocol SendMoneySelectAccountExternalDependenciesResolver {
    func resolve() -> UINavigationController
}
