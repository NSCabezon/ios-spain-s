enum MifidStep: Int {
    case mifid2 = 0
    case advisoryClauses
    case mifid1Simple
    case mifid1Complex
    case mfm

    var presentation: StepPresentation {
        switch self {
        case .mifid2,
             .advisoryClauses:
            return .modal
        case .mifid1Simple,
             .mifid1Complex,
             .mfm:
            return .inNavigation

        }
    }

    func presenter(forOperative operative: MifidOperative, withProvider presenterProvider: PresenterProvider) -> MifidPresenterProtocol? {
        switch self {
        case .mifid2:
            return mifid2StepPresenter(forOperative: operative, withProvider: presenterProvider)
        case .advisoryClauses:
            return advisoryClausesMifidStepPresenter(forOperative: operative, withProvider: presenterProvider)
        case .mifid1Simple:
            return mifid1SimplePresenter(forOperative: operative, withProvider: presenterProvider)
        case .mifid1Complex:
            return presenterProvider.mifid.mifid1ComplexStepPresenter
        case .mfm:
            return presenterProvider.mifid.mifidMfmComplexStepPresenter
        }
    }

    private func mifid2StepPresenter(forOperative operative: MifidOperative, withProvider presenterProvider: PresenterProvider) -> Mifid2StepPresenter {
        switch operative {
        case .fundsSubscription:
            return presenterProvider.mifid.mifid2StepPresenter() as FundSubscriptionMifid2StepPresenter
        case .fundsTransfer:
            return presenterProvider.mifid.mifid2StepPresenter() as FundTransferMifid2StepPresenter
        case .stocksBuy:
            return presenterProvider.mifid.mifid2StepPresenter() as BuyStocksMifid2StepPresenter
        case .stocksSell:
            return presenterProvider.mifid.mifid2StepPresenter() as SellStocksMifid2StepPresenter
        case .pensionsExtraordinaryContribution:
            return presenterProvider.mifid.mifid2StepPresenter() as PensionsMifid2StepPresenter
        }
    }

    private func advisoryClausesMifidStepPresenter(forOperative operative: MifidOperative, withProvider presenterProvider: PresenterProvider) -> MifidAdvisoryClausesStepPresenter {
        switch operative {
        case .stocksBuy:
            return presenterProvider.mifid.advisoryClausesMifidStepPresenter() as BuyStocksMifidAvisoryClausesPresenter
        case .stocksSell:
            return presenterProvider.mifid.advisoryClausesMifidStepPresenter() as SellStocksMifidAvisoryClausesPresenter
        case .pensionsExtraordinaryContribution:
            return presenterProvider.mifid.advisoryClausesMifidStepPresenter() as PensionsMifidAvisoryClausesPresenter
        case .fundsSubscription:
            return presenterProvider.mifid.advisoryClausesMifidStepPresenter() as FundSubscriptionMifidAvisoryClausesPresenter
        case .fundsTransfer:
            return presenterProvider.mifid.advisoryClausesMifidStepPresenter() as FundTransferMifidAvisoryClausesPresenter
        }
    }

    private func mifid1SimplePresenter(forOperative operative: MifidOperative, withProvider presenterProvider: PresenterProvider) -> Mifid1SimpleStepPresenter {
        switch operative {
        case .pensionsExtraordinaryContribution:
            return presenterProvider.mifid.mifid1SimplePresenter() as PensionMifid1StepPresenter
        case .stocksBuy:
            return presenterProvider.mifid.mifid1SimplePresenter() as BuyStockMifid1SimpleSetpPresenter
        case .stocksSell:
            return presenterProvider.mifid.mifid1SimplePresenter() as SellStockMifid1SimpleSetpPresenter
        case .fundsSubscription:
            return presenterProvider.mifid.mifid1SimplePresenter() as FundSubscriptionMifid1SimpleStepPresenter
        case .fundsTransfer:
            return presenterProvider.mifid.mifid1SimplePresenter() as FundTransferMifid1SimpleStepPresenter
        }
    }
}
