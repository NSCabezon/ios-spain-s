//
//  CachePolicy.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

class CachePolicy: Codable {

    private var validTimestamp: Int64

    init(timeValidInMillis: Int64) {
        let nowDouble = NSDate().timeIntervalSince1970
        validTimestamp = Int64(nowDouble * 1000) + timeValidInMillis
    }

    func isValid() -> Bool {
        let nowDouble = NSDate().timeIntervalSince1970
        let now = Int64(nowDouble * 1000)
        return now < validTimestamp
    }
}
