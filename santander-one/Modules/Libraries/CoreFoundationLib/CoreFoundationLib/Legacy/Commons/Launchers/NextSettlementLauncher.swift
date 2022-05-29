
public protocol NextSettlementLauncher {
    func gotoNextSettlement(_ cardEntity: CardEntity, cardSettlementDetailEntity: CardSettlementDetailEntity, isEnabledMap: Bool)
}
