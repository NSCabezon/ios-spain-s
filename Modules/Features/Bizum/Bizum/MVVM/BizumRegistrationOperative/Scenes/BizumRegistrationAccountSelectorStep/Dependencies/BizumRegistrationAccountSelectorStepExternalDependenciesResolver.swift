//
//  BizumRegistrationAccountSelectorStepExternalDependenciesResolver.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 25/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import UIKit

public protocol BizumRegistrationAccountSelectorStepExternalDependenciesResolver {
    func resolve() -> UINavigationController
}
