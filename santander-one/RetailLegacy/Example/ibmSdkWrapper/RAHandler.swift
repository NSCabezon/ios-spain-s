//
//  RAHandler.swift
//  tas_example_app
//
//  Copyright © 2018 com.ibm. All rights reserved.
//

import UIKit
import CoreFoundationLib

class RAHandler {
    
    private let TIMEOUT_IN_MS: Int32 = 10000
    
    
    static let sharedInstance = RAHandler()
    var appSessionId: String?
    private init(){
    } // prevent creating another instances.
    
    ///  create a session, set the PUID, and notify Pinpoint about the user activity
    ///
    /// - Parameters:
    ///   - appSessionId: the session id
    ///   - appPUID: the PUID
    func notifyLoginFlow(appSessionId:String,appPUID:String)  {
    }

    ///  create a session, set the PUID, and get the risk score
    ///
    /// - Parameters:
    ///   - appSessionId: the session id
    ///   - appPUID: the PUID
    /// - Returns: the risk assessment as string or failure string in case of failure
    func loginFlow(appSessionId:String,appPUID:String) -> String {
        return ""
    }

    ///  create a session, create an activity object, add key/value pairs, and get the risk score
    ///
    /// - Parameters:
    ///   - appSessionId: he session id
    /// - Returns: the risk assessment as string or failure string in case of failure
    func registerFlow(appSessionId:String) -> String {

        return ""
    }

    /// Make transfer flow
    /// Create an activity object, add key/value pairs, get the risk score, and destroy the activity object
    /// - Parameter amountTotransfer:  amount to transfer
    /// - Returns: the risk assessment as string or failure string in case of failure
    func makeTransferFlow(amountTotransfer:String) -> String {
        
        return ""
    }
    

    
    /// Send the user activity to the server and receive risk score in return
    ///
    /// - Parameters:=
    /// Destroy the session object
    func destroySession() {

    }
    

    
    func initialize() {
    }
}

extension RAHandler: TrusteerRepositoryProtocol {}
