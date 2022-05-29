//
//  Async.swift
//  SANLibraryV3
//
//  Created by Juan Carlos López Robles on 12/16/21.
//

import Foundation

func Async(queue: DispatchQueue, completion: @escaping ()-> Void) {
    queue.async {
        completion()
    }
}
