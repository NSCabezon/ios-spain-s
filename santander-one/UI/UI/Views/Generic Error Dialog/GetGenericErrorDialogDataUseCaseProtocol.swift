//
//  GetGenericErrorDialogDataUseCaseProtocol.swift
//  UI
//
//  Created by Rodrigo Jurado on 29/11/21.
//

import CoreFoundationLib

public protocol GetGenericErrorDialogDataUseCaseProtocol: UseCase<Void, GetGenericErrorDialogDataUseCaseOkOutput, StringErrorOutput> { }

public struct GetGenericErrorDialogDataUseCaseOkOutput {
    let webUrl: URL
    let phone: String

    public init(webUrl: URL, phone: String) {
        self.webUrl = webUrl
        self.phone = phone
    }
}
