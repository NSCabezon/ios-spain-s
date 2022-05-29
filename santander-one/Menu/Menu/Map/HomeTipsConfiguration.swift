import CoreFoundationLib

public final class HomeTipsConfiguration {
    let section: String
    let tips: [HomeTipsViewModel]

    init(section: String, tips: [HomeTipsViewModel]) {
        self.section = section
        self.tips = tips
    }
}
