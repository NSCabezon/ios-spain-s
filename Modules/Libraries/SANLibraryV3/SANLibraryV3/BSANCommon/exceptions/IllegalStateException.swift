//
// Created by Toni Moreno on 15/11/17.
// Copyright (c) 2017 Toni. All rights reserved.
//

import Foundation

public class IllegalStateException: Error {

    var message: String?

    public init(_ message: String? = nil) {
        self.message = message
    }

    public var localizedDescription: String {
        return message ?? ""
    }

}
