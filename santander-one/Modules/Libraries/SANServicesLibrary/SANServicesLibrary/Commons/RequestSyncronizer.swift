//
//  RequestSyncronizer.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 12/5/21.
//

public protocol RequestSyncronizer {
    /// Method to avoid multiple-calls to the same request at the same time. It creates a semaphore with an identifier for each "functionName + key".
    /// - Parameters:
    ///   - functionName: The functionName of the caller
    ///   - key: The uniqueKey to identify the semaphore (for example, you can use an Account)
    ///   - requestBlock: Block to perform the network request.
    func syncronizeRequest<Response>(for functionName: String, by key: String, requestBlock: () -> Result<Response, Error>) -> Result<Response, Error>
}
