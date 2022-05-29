//
//  FileClient.swift
//  iOS-Public-Files
//
//  Created by Johann Casique on 07/02/2018.
//  Copyright © 2018 Johann Casique. All rights reserved.
//

import Foundation

public struct FileClient {
   
    private let appConfigExtension = "txt"
    private func fileURL(_ path: String) -> URL {
        return FileManager.documentDirectoryURL.appendingPathComponent(path).appendingPathExtension(appConfigExtension)
    }
    
    public init() { }
    
    public func set(_ fileString: String, path: String ) throws {
        let components = (path as NSString).pathComponents.dropLast()
        var url = FileManager.documentDirectoryURL
        let fileManager = FileManager.default
        for component in components {
            url = url.appendingPathComponent(component)
            if !fileManager.fileExists(atPath: url.absoluteString) {
                 try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
        }
        try? fileString.write(to: fileURL(path), atomically: true, encoding: .utf8)
    }
    
    public func remove(path: String) {
        let file = fileURL(path)
        do {
            try FileManager.default.removeItem(at: file)
        } catch {}
    }
    
    public func get(_ path: String) -> String? {
        do {
            return try String(contentsOf: fileURL(path))
        } catch {
            return nil
        }
    }
    
}

