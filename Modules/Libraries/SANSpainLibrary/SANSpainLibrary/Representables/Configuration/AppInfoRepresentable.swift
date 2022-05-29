//
//  AppInfoRepresentable.swift
//  SANServicesLibrary
//
//  Created by José María Jiménez Pérez on 29/7/21.
//

public protocol AppInfoRepresentable {
    var bundleIdentifier: String { get }
    var versionName: String { get }
}
