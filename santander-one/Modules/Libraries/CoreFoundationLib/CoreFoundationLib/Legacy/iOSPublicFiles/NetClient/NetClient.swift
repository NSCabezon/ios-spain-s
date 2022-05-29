//
//  RestClient.swift
//  iOS-Public-Files
//
//  Created by Johann Casique on 07/02/2018.
//  Copyright © 2018 Johann Casique. All rights reserved.
//
import Foundation

public enum NetClientResponse {
    case notLoaded
    case loaded(response: String, date: Date)
}

public protocol NetClient {
    func loadURL(_ url: String, date: Date?) -> NetClientResponse
}
