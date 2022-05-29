//
//  LastMovementsConfiguration.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 27/07/2020.
//

final public class LastMovementsConfiguration {
    public enum FractionableSection {
        case lastMovements
        case fundableAccounts
        case fractionableCards
    }
    let fractionableSection: FractionableSection
    let lastMovementesViewModel: WhatsNewLastMovementsViewModel?

    public init(_ fractionableSection: FractionableSection, lastMovementesViewModel: WhatsNewLastMovementsViewModel) {
        self.fractionableSection = fractionableSection
        self.lastMovementesViewModel = lastMovementesViewModel
    }

    public init(_ fractionableSection: FractionableSection) {
        self.fractionableSection = fractionableSection
        self.lastMovementesViewModel = nil
    }
}
