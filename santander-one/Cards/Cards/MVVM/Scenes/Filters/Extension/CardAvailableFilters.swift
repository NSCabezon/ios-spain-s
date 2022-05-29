//
//  CardAvailableFilters.swift
//  Cards
//
//  Created by Gloria Cano López on 26/4/22.
//
import CoreDomain

final public class CardAvailableFilters: CardTransactionAvailableFiltersRepresentable {
    public var byAmount: Bool = false
    public var byExpenses: Bool = false
    public var byTypeOfMovement: Bool = false
    public var byConcept: Bool = false
    
    public init() {}
    
    func configure(byAmount: Bool, byExpenses: Bool, byTypeOfMovement: Bool, byConcept: Bool){
        self.byAmount = byAmount
        self.byExpenses = byExpenses
        self.byTypeOfMovement = byTypeOfMovement
        self.byConcept = byConcept
    }
}
