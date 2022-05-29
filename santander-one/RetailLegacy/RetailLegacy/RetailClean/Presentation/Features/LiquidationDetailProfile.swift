import CoreFoundationLib

class LiquidationDetailProfile: BaseProductDetailProfile<ImpositionAndLiquidation>, ProductDetailProfile {
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_settlementDetail")
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.DepositLiquidationDetail().page
    }

    // MARK: -

    private let product: ImpositionAndLiquidation

    init(product: GenericProductProtocol?, errorHandler: GenericPresenterErrorHandler, dependencies: PresentationComponent, shareDelegate: ShowShareType?) {
        self.product = product as! ImpositionAndLiquidation
        super.init(errorHandler: errorHandler, dependencies: dependencies, shareDelegate: shareDelegate)
    }
    
    override func extractProduct() -> ImpositionAndLiquidation {
        return product
    }
    
    override func convertToProductHeader(element: ImpositionAndLiquidation, position: Int) -> CarouselItem {
        let imposition = element.imposition
        let data = ProductHeader(
            title: impositionUI(from: imposition.subcontract),
            styleSubtitle: impositionDescription(from: imposition.deposit?.getAliasCamelCase() ?? "", TAE: imposition.TAE ?? ""),
            amount: imposition.settlementAmount,
            pendingText: nil,
            isPending: false,
            isCopyButtonAvailable: false,
            copyTag: 1,
            isBigSeparator: false,
            shareDelegate: self)
        return CarouselGenericCell(data: data)
    }
    
    func getInfo() -> [TableModelViewSection] {
        var sections = [TableModelViewSection]()
        
        sections.append(contentsOf: makeDateSection())
        
        let loadingSection = LoadingSection()
        let loading = SecondaryLoadingModelView(dependencies: dependencies)
        loadingSection.add(item: loading)
        sections.append(loadingSection)
        
        return sections
    }
    
    func getAllInfo(_ liquidationDetail: LiquidationDetailList) -> [TableModelViewSection] {
        var sections = [TableModelViewSection]()
        
        sections.append(contentsOf: makeDateSection())
        
        let totalDebeSection = ProductInfoSection()
        let totalDebeViewModel = ProductDetailInfoViewModel(
            infoTitle: dependencies.stringLoader.getString("productDetail_label_debit"),
            info: liquidationDetail.totalDebit.getFormattedAmountUI(2),
            infoStylable: nil,
            privateComponent: dependencies,
            copyTag: nil,
            shareDelegate: self)
        
        totalDebeSection.add(item: totalDebeViewModel)
        sections.append(totalDebeSection)
        
        let totalHaber = ProductInfoSection()
        let totalHaberViewModel = ProductDetailInfoViewModel(
            infoTitle: dependencies.stringLoader.getString("productDetail_label_credit"),
            info: liquidationDetail.totalCredit.getFormattedAmountUI(2),
            infoStylable: nil,
            privateComponent: dependencies,
            copyTag: nil,
            shareDelegate: self)
        totalHaber.add(item: totalHaberViewModel)
        sections.append(totalHaber)
        
        if let liquidationItems = liquidationDetail.liquidationItemDetailList {
            for node in liquidationItems {
                if let infoTitle = node.liquidationDescription {
                    let infoSection = ProductInfoSection()
                    let viewModel = ProductDetailInfoViewModel(
                        infoTitle: LocalizedStylableText(text: infoTitle, styles: nil),
                        info: node.settlementAmount.getFormattedAmountUI(2),
                        infoStylable: nil,
                        privateComponent: dependencies,
                        copyTag: nil,
                        shareDelegate: self)
                    
                    infoSection.add(item: viewModel)
                    sections.append(infoSection)
                }
            }
        }
        
        return sections
    }
    
    func requestDetail(completion: @escaping ([TableModelViewSection]?) -> Void) {
        let uc = dependencies.useCaseProvider.getDetailLiquidationUseCase(input: GetDetailLiquidationUseCaseInput(impositionDTO: product.imposition.dto, liquidationDTO: product.liquidation.dto))
        UseCaseWrapper(with: uc, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] result in
            
            guard let strongSelf = self else { return }
            completion(strongSelf.getAllInfo(result.liquidationDetailList))
            
        }, onError: { error in
            RetailLogger.e(self.logTag, "LiquidationDetailDTO error \(error?.getErrorDesc() ?? "")")
            completion(nil)
        })
        
    }
    
    func removeLoading(sections: [TableModelViewSection]) -> [TableModelViewSection] {
        return sections.filter { !($0 is LoadingSection) }
    }
    
    // MARK: Privates
    private func impositionUI(from subContract: String) -> String {
        let impositionsTitle = dependencies.stringLoader.getString("toolbar_title_imposition").text.uppercased()
        let impositionNumber = dependencies.stringLoader.getString("deposits_label_number", [StringPlaceholder(StringPlaceholder.Placeholder.number, subContract)]).text
        return "\(impositionsTitle) \(impositionNumber)"
    }
    
    private func impositionDescription(from contractType: String, TAE: String) -> LocalizedStylableText {
        let contract = dependencies.stringLoader.getString("detailImposition_text_APR", [StringPlaceholder(StringPlaceholder.Placeholder.name, contractType), StringPlaceholder(StringPlaceholder.Placeholder.number, TAE)])
        return contract
    }
    
    private func makeDateSection() -> [TableModelViewSection] {
        var sections = [TableModelViewSection]()
        
        if let initialDate = product.liquidation.initialDate {
            let initialDateSection = ProductInfoSection()
            let initialDateViewModel = ProductDetailInfoViewModel(
                infoTitle: dependencies.stringLoader.getString("productDetail_label_start"),
                info: dependencies.timeManager.toString(date: initialDate, outputFormat: .d_MMM_yyyy),
                privateComponent: dependencies,
                shareDelegate: self)
            initialDateSection.add(item: initialDateViewModel)
            sections.append(initialDateSection)
        }
        
        if let expirationDate = product.liquidation.expirationDate {
            let expirationDateSection = ProductInfoSection()
            let expirationDateViewModel = ProductDetailInfoViewModel(
                infoTitle: dependencies.stringLoader.getString("productDetail_label_end"),
                info: dependencies.timeManager.toString(date: expirationDate, outputFormat: .d_MMM_yyyy),
                privateComponent: dependencies,
                shareDelegate: self)
            expirationDateSection.add(item: expirationDateViewModel)
            sections.append(expirationDateSection)
        }
        
        setFirstElement(sections: sections)
        
        return sections
    }
    
}
