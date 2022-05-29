//
//  LastMovementsListConstants.swift
//  Commons
//
//  Created by Ignacio González Miró on 22/07/2020.
//

public struct LastMovementsListPage: PageTrackable {
    public var page: String
    public init(isLastMovements: Bool) {
        self.page = !isLastMovements
            ? "whatsnew_pagos_fraccionables"
            : "whatsnew_movimientos_sin_leer"
    }
}
