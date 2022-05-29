//
//  SegmentedUserRepositoryProtocolMock.swift
//  QuickSetup
//
//  Created by Jose Camallonga on 15/12/21.
//

import Foundation
import CoreDomain
import CoreFoundationLib
import OpenCombine

public final class SegmentedUserRepositoryProtocolMock: SegmentedUserRepository {
    public init() {}
    
    public func getSegmentedUser() -> SegmentedUserDTO? {
        return nil
    }
    
    public func getSegmentedUserSpb() -> [SegmentedUserTypeDTO]? {
        return nil
    }
    
    public func getSegmentedUserGeneric() -> [SegmentedUserTypeDTO]? {
        return nil
    }
    
    public func getCommercialSegment() -> AnyPublisher<CommercialSegmentRepresentable?, Never> {
        return Empty()
            .eraseToAnyPublisher()
    }
    
    public func remove() {}
    
    public func load(withBaseUrl url: String) {}
    
    public func load(baseUrl: String, publicLanguage: PublicLanguage) {}
}
