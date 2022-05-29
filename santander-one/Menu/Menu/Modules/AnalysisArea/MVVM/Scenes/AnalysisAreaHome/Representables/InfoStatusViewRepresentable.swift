//
//  InfoStatusViewRepresentable.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 23/2/22.
//

import Foundation

protocol InfoStatusViewRepresentable {
    var statusInfoString: String { get }
    var statusErrorString: String { get }
    var isErrorViewShown: Bool { get }
    var mustUpdateEntityWithCodes: [String] { get }
}
