//
//  Schedulers.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/10/21.
//

import Foundation
import OpenCombine
import OpenCombineDispatch

public struct Schedulers {
    public static let main = DispatchQueue.OCombine(.main)
    public static let global = DispatchQueue.OCombine(.global())
    public static let background = DispatchQueue.OCombine(.global(qos: .background))
}
