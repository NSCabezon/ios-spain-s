//
//  IBANRepresentable+extension.swift
//  TransferOperatives
//
//  Created by Mario Rosales Maillo on 23/3/22.
//

import CoreDomain
import CoreFoundationLib

extension IBANRepresentable {
    public func bankLogoURLFrom(baseURLProvider: BaseURLProvider) -> String? {
        guard let entityCode = self.getEntityCode(offset: 4),
              let baseURL = baseURLProvider.baseURL
        else { return nil }
        return String(format: "%@%@/%@_%@%@",
                      baseURL,
                      GenericConstants.relativeURl,
                      self.countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
}
