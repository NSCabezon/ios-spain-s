//
//  SanKeyNavigatorProtocol.swift
//  RetailLegacy
//
//  Created by Andres Aguirre Juarez on 11/11/21.
//

import Foundation
import UIKit

public protocol SanKeyNavigatorProtocol {
    func openSanKeyNavigatorFrom(_ navController: UINavigationController, delegate: SanKeyValidatorDelegate)
}
