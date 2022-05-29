//
//  RememberedLoginBackgroundViewModel.swift
//  Login
//
//  Created by Juan Carlos López Robles on 12/3/20.
//

import Foundation

struct RememberedLoginBackgroundViewModel {
    private let backgroundType: RememberedLoginBackgroundType
    enum LoginRememberedBackgroundImage {
        case assets(name: String)
        case documents(data: Data)
    }
    
    init(backgroundType: RememberedLoginBackgroundType) {
        self.backgroundType = backgroundType
    }
    
    func image() -> LoginRememberedBackgroundImage {
        switch self.backgroundType {
        case .assets(let name): return .assets(name: name)
        case .documents(let data): return .documents(data: data)
        }
    }
}
