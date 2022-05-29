import Foundation

public class PersonBasicDataAssemble: BSANAssemble {

    private static let ourInstance = PersonBasicDataAssemble("ACBDPESPConsultasExceDescr", "/SCH_BDPGPO_INT_ENS/ws/BDPGPO_Def_Listener")

    static func getInstance() -> PersonBasicDataAssemble {
        return ourInstance
    }
}

