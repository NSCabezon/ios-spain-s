//
//  LoadingTipsRepositoryProtocol.swift
//  Commons
//
//  Created by Luis Escámez Sánchez on 04/02/2020.
//

import Foundation


public protocol LoadingTipsRepositoryProtocol {
    func getLoadingTips() -> LoadingTipsListDTO?
}
