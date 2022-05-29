import SANLegacyLibrary

class ExtraContributionPensionOperativeData: ProductSelection<Pension> {
    var extraContributionPension: ExtraContributionPension?
    var advices: PensionMifidDTO?

    init(pension: Pension?) {
        super.init(list: [], productSelected: pension, titleKey: "toolbar_title_extraContribution", subTitleKey: "extraContribution_label_selectPlan")
    }
    
    func updatePre(pensions: [Pension]) {
        self.list = pensions
    }
}
