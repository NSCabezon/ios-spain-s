import UIKit

public enum ColorsByNameEngineType: Int, CaseIterable {
    case first = 0
    case second
    case third
    case quarter
    case fifth
    case sixth
    case seventh
    case eighth
    case ninth
}

public class ColorsByNameEngine {
    private var colorables: [String: ColorsByNameEngineType] = [:]
    private let colorsPalette: [ColorsByNameEngineType] = ColorsByNameEngineType.allCases
    private var assignableColorsPalette: [ColorsByNameEngineType] {
        didSet {
            guard self.assignableColorsPalette.count == 0 else { return }
            self.assignableColorsPalette = self.colorsPalette
        }
    }
    
    public init() {
        self.assignableColorsPalette = self.colorsPalette
    }
    
    public func get(_ name: String) -> ColorsByNameEngineType {
        let nameConverted = name.trim().lowercased()
        guard let color = self.colorables[nameConverted] else {
            return self.newColor(nameConverted)
        }
        return color
    }
    
    private func newColor(_ name: String) -> ColorsByNameEngineType {
        guard let color = self.assignableColorsPalette.first else { return .first }
        self.assignableColorsPalette = Array(self.assignableColorsPalette.dropFirst())
        self.colorables[name] = color
        return color
    }
}

public class ColorsByNameViewModel {
    public let type: ColorsByNameEngineType
    
    public init(_ type: ColorsByNameEngineType) {
        self.type = type
    }
}
