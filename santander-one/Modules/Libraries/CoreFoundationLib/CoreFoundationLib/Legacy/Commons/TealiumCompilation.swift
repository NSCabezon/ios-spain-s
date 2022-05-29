//
//  TealiumCompilation.swift
//  Commons
//
//  Created by Iván Estévez Nieto on 18/3/21.
//

import Foundation

public protocol TealiumCompilationProtocol {
    var profile: String { get }
    var appName: String { get }
    var clientKey: String { get }
    var clientIdUpperCased: Bool { get }
}
