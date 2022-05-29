//
//  UserSegmentProtocol.swift
//  GlobalPosition
//
//  Created by Laura González on 17/03/2021.
//


public protocol UserSegmentProtocol {
    func getUserSegment(_ completion: @escaping (SegmentTypeEntity, String?) -> Void)
}
