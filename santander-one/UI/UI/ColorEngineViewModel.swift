import CoreFoundationLib

public protocol ColorEngineViewModelProtocol {
    var name: String { get set }
}

public extension ColorEngineViewModelProtocol {
    var capitalName: String {
        return self.name.capitalizedIgnoringNumbers()
    }
    
    var avatarColor: UIColor {
        return self.colorsByNameViewModel.color
    }
    
    var avatarName: String {
        return self.capitalName.nameInitials
    }
    
    var colorsByNameViewModel: ColorsByNameViewModel {
        let colorsEngine = ColorsByNameEngine()
        let colorType = colorsEngine.get(name)
        return ColorsByNameViewModel(colorType)
    }
}
