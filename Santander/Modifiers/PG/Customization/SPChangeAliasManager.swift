//
//  SPChangeAliasManager.swift
//  Santander
//
//  Created by Alvaro Royo on 5/4/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain

class SPChangeAliasManager: ProductAliasManagerProtocol {
    func getProductAlias(for aliasType: ProductTypeEntity) -> ProductAlias? {
        let regExp = CharacterSet(charactersIn: " 0123456789ABCDEFGHIJKLMNÑOPQRSTUVWXYZabcdefghijklmnñopqrstuvwxyz\\/-_.,ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ")

         switch aliasType {
         case .card, .account: return ProductAlias(charSet: regExp, maxChars: 20)
         default: return nil
         }
    }
}
