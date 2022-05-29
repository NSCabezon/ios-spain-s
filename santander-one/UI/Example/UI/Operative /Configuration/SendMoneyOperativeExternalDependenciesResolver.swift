 //
//  SendMoneyOperativeExternalDependenciesResolver.swift
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
import Operative

public protocol SendMoneyOperativeExternalDependenciesResolver: NavigationBarExternalDependenciesResolver, SendMoneySelectAccountExternalDependenciesResolver {
    func resolve() -> UINavigationController
}
