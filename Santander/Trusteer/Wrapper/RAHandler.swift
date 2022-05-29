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
    
    private var sessionRef: TAS_OBJECT? // The session object
    
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
        // Create a session
        var tasRetCode:TAS_RESULT = SdkHandler.singleton().createSession(&sessionRef,appSessionId)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function) error on createSession")
            return
        }
        
        // Set the PUID
        tasRetCode = SdkHandler.singleton().setPUID(appPUID)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function) error on setPUID")
            return
        }
        // Notify Pinpoint regarding the user's "login" activity
        notifyUserActivity(activityName:"login",activityData:nil)
        self.appSessionId = appSessionId
    }

    ///  create a session, set the PUID, and get the risk score
    ///
    /// - Parameters:
    ///   - appSessionId: the session id
    ///   - appPUID: the PUID
    /// - Returns: the risk assessment as string or failure string in case of failure
    func loginFlow(appSessionId:String,appPUID:String) -> String {
        NSLog("\(#function)")
        
        // Create a session
        var tasRetCode:TAS_RESULT = SdkHandler.singleton().createSession(&sessionRef,appSessionId)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function) error on createSession")
            return SdkHandler.singleton().getMessageForResult(tasRetCode)
        }
        
        // Set the PUID
        tasRetCode = SdkHandler.singleton().setPUID(appPUID)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function) error on setPUID")
            return SdkHandler.singleton().getMessageForResult(tasRetCode)
        }
        self.appSessionId = appSessionId
        
        // Get the risk assessment
        let risk:String = getRiskAssessment(activityName:"login",activityData:nil)
        NSLog("\(#function):risk score=\(risk)")
        return risk
    }

    ///  create a session, create an activity object, add key/value pairs, and get the risk score
    ///
    /// - Parameters:
    ///   - appSessionId: he session id
    /// - Returns: the risk assessment as string or failure string in case of failure
    func registerFlow(appSessionId:String) -> String {
        NSLog("\(#function)")

        // Create a session
        var tasRetCode:TAS_RESULT = SdkHandler.singleton().createSession(&sessionRef,appSessionId)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function) error on createSession")
            return SdkHandler.singleton().getMessageForResult(tasRetCode)
        }

        // Get reference to the activity object
        var tasRaActDataRef:TAS_RA_ACTIVITY_DATA?
        tasRetCode = SdkHandler.singleton().createActivityData(&tasRaActDataRef)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function):error=\(String(describing: SdkHandler.singleton().getMessageForResult(tasRetCode))) createActivityData ")
            return SdkHandler.singleton().getMessageForResult(tasRetCode)
        }

        // Add key/value to the activity object
        tasRetCode  = SdkHandler.singleton().activityAddData(tasRaActDataRef!,"new_account", "true")
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function):error=\(String(describing: SdkHandler.singleton().getMessageForResult(tasRetCode))) activityAddData ")
            return SdkHandler.singleton().getMessageForResult(tasRetCode)
        }

        // Get the risk assessment
        let risk:String = getRiskAssessment(activityName:"new_account",activityData:tasRaActDataRef!)

        // Destroy the activity data object
        tasRetCode  = SdkHandler.singleton().destroyActivityData(tasRaActDataRef!)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function):error=\(String(describing: SdkHandler.singleton().getMessageForResult(tasRetCode))) destroyActivityData ")
        }

        return risk
    }

    /// Make transfer flow
    /// Create an activity object, add key/value pairs, get the risk score, and destroy the activity object
    /// - Parameter amountTotransfer:  amount to transfer
    /// - Returns: the risk assessment as string or failure string in case of failure
    func makeTransferFlow(amountTotransfer:String) -> String {
        NSLog("\(#function):amountTotransfer=\(amountTotransfer)")

        // Get reference to the activity object
        var tasRaActDataRef:TAS_RA_ACTIVITY_DATA?
        var tasRetCode:TAS_RESULT = SdkHandler.singleton().createActivityData(&tasRaActDataRef)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function):error=\(String(describing: SdkHandler.singleton().getMessageForResult(tasRetCode))) createActivityData ")
            return SdkHandler.singleton().getMessageForResult(tasRetCode)
        }
        
        // Add key/value to the activity object
        tasRetCode  = SdkHandler.singleton().activityAddData(tasRaActDataRef!,"amount",amountTotransfer)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function):error=\(String(describing: SdkHandler.singleton().getMessageForResult(tasRetCode))) activityAddData ")
            return SdkHandler.singleton().getMessageForResult(tasRetCode)
        }
        
        //Get the risk assessment
        let risk:String = getRiskAssessment(activityName: "transaction", activityData: tasRaActDataRef!)
        
        // Destroy the activity data object
        tasRetCode  = SdkHandler.singleton().destroyActivityData(tasRaActDataRef!)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function):error=\(String(describing: SdkHandler.singleton().getMessageForResult(tasRetCode))) destroyActivityData ")
        }
        
        return risk
    }
    
    ///  Send the user activity to the server
    ///
    /// - Parameters:
    ///   - activityName: the activity name
    ///   - activityData: (optional) the activity data
    func notifyUserActivity(activityName:String,activityData: TAS_RA_ACTIVITY_DATA?) {
        NSLog("\(#function):activityName=\(activityName)")
        
        let tasRetCode:TAS_RESULT = SdkHandler.singleton().notifyUserActivity(sessionRef!,activityName,( activityData != nil ? activityData : nil),TIMEOUT_IN_MS)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function):error=\(String(describing: SdkHandler.singleton().getMessageForResult(tasRetCode))) notifyUserActivity ")
        }
        
    }
    
    /// Send the user activity to the server and receive risk score in return
    ///
    /// - Parameters:
    ///   - activityName: the activity name
    ///   - activityData: (optional) the activity data
    /// - Returns: the risk assessment as string or failure string in case of failure
    func getRiskAssessment(activityName:String,activityData:TAS_RA_ACTIVITY_DATA? ) ->String{
        NSLog("\(#function):activityName=\(activityName)")
        
        var riskAssessment:TAS_RA_RISK_ASSESSMENT = TAS_RA_RISK_ASSESSMENT()
        
        let tasRetCode:TAS_RESULT = SdkHandler.singleton().getRiskAssessment(sessionRef!, activityName,( activityData != nil ? activityData : nil), &riskAssessment, TIMEOUT_IN_MS)
        if (tasRetCode != TAS_RESULT_SUCCESS)
        {
            NSLog("\(#function) error on createSession")
            return SdkHandler.singleton().getMessageForResult(tasRetCode)
        }
        
        let risk:String = riskAssessmentToString(risk: riskAssessment,title: activityName)
        NSLog("\(#function):risk assessment=\(risk)")
        
        return risk
    }
    
    /// Destroy the session object
    func destroySession() {
        NSLog("\(#function)")
        self.appSessionId = nil
        if sessionRef != nil{
            let tasRetCode:TAS_RESULT = SdkHandler.singleton().destroySession(sessionRef)
            if (tasRetCode != TAS_RESULT_SUCCESS)
            {
                NSLog("\(#function):error=\(String(describing: SdkHandler.singleton().getMessageForResult(tasRetCode))) destroySession ")
                sessionRef = nil
                return
            }
        }
    }
    
    /// Risk assessment structure to string
    ///
    /// - Parameter risk: the risk assessment structure
    /// - Returns: risk assessment as a string
    func riskAssessmentToString(risk:  TAS_RA_RISK_ASSESSMENT,title:String) ->String{
        NSLog("\(#function)")
        
        let formatedRisk:String="[\(title.uppercased()) ACTIVITY]\n\nReason=\(SdkHandler.singleton().getRiskReason(risk)!)\nReasonId=\(risk.reason_id)\nRecommendation=\(SdkHandler.singleton().getRiskRecommendation(risk)!)\nResolutionId=\(SdkHandler.singleton().getRiskResolutionId(risk)!)\nRiskScore=\(risk.risk_score)"
        
        return formatedRisk
    }
    
    func initialize() {
        SdkHandler.singleton().initialize()
    }
}

extension RAHandler: TrusteerRepositoryProtocol {}
