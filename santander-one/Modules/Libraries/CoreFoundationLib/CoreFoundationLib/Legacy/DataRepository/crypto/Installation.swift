//
//  Installation.swift
//  iOS Base
//
//  Created by Toni Moreno on 5/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public class Installation {
    public static var keychainService: KeychainService?
    
    private static var sID: String? = nil

    private static let fakeMagic: String = "34384343-6e86-47da-9d65-e5568e884541"

    private static let lock = NSLock()
    
    public static func id() throws -> String {
        let globalQueue = DispatchQueue.global()
        do {
            try globalQueue.sync {
                self.lock.lock()
                sID = try readInstallationFile()
                if sID == nil {
                    try writeInstallationFile()
                    sID = try readInstallationFile()
                }
                self.lock.unlock()
            }
        } catch is IOException {
            globalQueue.async {
                self.lock.unlock()
            }
            return fakeMagic
        }
        return sID!
    }

    private static func writeInstallationFile() throws {
        let id = UUID().uuidString
        do {
            try keychainService?.saveMagic(data: id)
        } catch {
            print(error)
            throw IOException()
        }
    }

    private static func readInstallationFile() throws -> String? {
        do {
            let id = try keychainService?.loadMagic()
            return id
        } catch {
            throw IOException()
        }
    }


}
