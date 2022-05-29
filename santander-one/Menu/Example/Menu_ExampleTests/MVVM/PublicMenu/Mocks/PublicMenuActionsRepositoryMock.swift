//
//  PublicMenuActionsRepositoryMock.swift
//  Menu_ExampleTests
//
//  Created by alvola on 1/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//
import CoreDomain
import OpenCombine

struct PublicMenuActionsRepositoryMock: PublicMenuActionsRepository {
    func send() {
        
    }
    
    func reloadPublicMenu() -> AnyPublisher<Bool, Never> {
        return Just(false).eraseToAnyPublisher()
    }
}
