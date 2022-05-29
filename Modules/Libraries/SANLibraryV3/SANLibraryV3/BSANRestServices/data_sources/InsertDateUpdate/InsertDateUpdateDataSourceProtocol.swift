//
//  InsertDateUpdateDataSourceProtocol.swift
//  GlobalPosition
//
//  Created by Carlos Monfort Gómez on 4/5/21.
//

import Foundation

protocol InsertDateUpdateDataSourceProtocol: RestDataSource {
    func insertDateUpdate() throws -> BSANResponse<Void>
}
