struct ImpositionAndLiquidation {
    let imposition: Imposition
    let liquidation: Liquidation
}

extension ImpositionAndLiquidation: GenericProductProtocol {}

extension ImpositionAndLiquidation: Equatable {
    static func == (lhs: ImpositionAndLiquidation, rhs: ImpositionAndLiquidation) -> Bool {
        return lhs.imposition == rhs.imposition && lhs.liquidation == rhs.liquidation
    }
}
