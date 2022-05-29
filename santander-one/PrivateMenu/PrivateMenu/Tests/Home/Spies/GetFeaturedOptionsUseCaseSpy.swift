//
//  GetFeaturedOptionsUseCaseSpy.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 4/5/22.
//

import CoreDomain
import OpenCombine
import PrivateMenu

class GetFeaturedOptionsUseCaseSpy: GetFeaturedOptionsUseCase {
    var fetchFeaturedOptionsCalled: Bool = false
    
    func fetchFeaturedOptions() -> AnyPublisher<[PrivateMenuOptions: String], Never> {
        fetchFeaturedOptionsCalled = true
        let options: [PrivateMenuOptions: String] = [.globalPosition: "highlightMenu", .myProducts: "", .bills: ""]
        return Just(options).setFailureType(to: Never.self).eraseToAnyPublisher()
    }
}
