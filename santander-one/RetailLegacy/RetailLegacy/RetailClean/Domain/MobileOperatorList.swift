import SANLegacyLibrary

struct MobileOperatorList {
    let list: [MobileOperator]
    
    init(mobileOperatorListDTO: MobileOperatorListDTO) {
        self.list = mobileOperatorListDTO.mobileOperatorList?.map({MobileOperator($0)}) ?? [MobileOperator]()
    }
}

extension MobileOperatorList: OperativeParameter {}
