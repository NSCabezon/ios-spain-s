//
// Created by Guillermo on 23/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation

struct PublicFilesEnvironment: CustomStringConvertible, Codable {

    static func createFrom(publicFilesEnvironment: PublicFilesEnvironmentDTO) -> PublicFilesEnvironment {
        return PublicFilesEnvironment(publicFilesEnvironment)
    }

    private var publicFilesEnvironment: PublicFilesEnvironmentDTO

    init(_ publicFilesEnvironment: PublicFilesEnvironmentDTO) {
        self.publicFilesEnvironment = publicFilesEnvironment
    }

    func getPublicFilesEnvironment() -> PublicFilesEnvironmentDTO {
        return publicFilesEnvironment
    }

    var name: String {
        return publicFilesEnvironment.name!
    }

    var urlBase: String {
        return publicFilesEnvironment.urlBase!
    }

    var description: String {
        return "\(name): \(urlBase)"
    }

}
