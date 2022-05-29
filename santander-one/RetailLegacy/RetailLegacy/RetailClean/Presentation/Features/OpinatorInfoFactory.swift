class OpinatorInfoTable<T: OpinatorInfo> {
    private var table: [OpinatorPage: T]
    
    init(list: [T]) {
        self.table = list.reduce([:]) { result, info in
            var new = result
            new[info.page] = info
            return new
        }
    }
    
    func getInfo(ofPage page: OpinatorPage) -> T? {
        return table[page]
    }
}

struct OpinatorInfoFactory<T: OpinatorInfo> {
    
    private weak var _opinatorInfoTable: OpinatorInfoTable<T>?
    
    mutating func info(ofPage page: OpinatorPage) -> T? {
        return getOpinatorInfoTable().getInfo(ofPage: page)
    }
    
    private mutating func getOpinatorInfoTable() -> OpinatorInfoTable<T> {
        if let list = _opinatorInfoTable {
            return list
        }
        
        let list = OpinatorInfoTable<T>(list: T.allCases as? [T] ?? [])
        _opinatorInfoTable = list
        return list
    }
}
