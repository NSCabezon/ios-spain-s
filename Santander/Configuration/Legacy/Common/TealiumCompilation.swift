//
//  TealiumCompilation.swift
//  Santander
//
//  Created by Iván Estévez Nieto on 18/3/21.
//

import Foundation
import CoreFoundationLib

final class TealiumCompilation: TealiumCompilationProtocol {
    let clientKey: String = "cod_cliente"
    let clientIdUpperCased: Bool = false
    let profile: String = "mobileapps"
    let account = "santander"
    let appName = "Santander Retail"
}
