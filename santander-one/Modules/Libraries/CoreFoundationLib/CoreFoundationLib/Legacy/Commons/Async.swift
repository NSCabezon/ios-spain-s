//
//  Async.swift
//  Commons
//
//  Created by César González Palomino on 31/01/2020.
//

import Foundation

public struct Async {
    
    public static func main(_ completion: @escaping () -> Void) {
        DispatchQueue.main.async(execute: completion)
    }
    
    public static func after(seconds: Double = 1.0, _ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.delay(inSeconds: seconds), execute: completion)
    }
}
