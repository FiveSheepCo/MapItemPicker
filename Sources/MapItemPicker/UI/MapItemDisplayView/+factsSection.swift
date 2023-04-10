import SwiftUI

extension MapItemDisplaySheet {
    
    struct Fact: Identifiable {
        let id = UUID()
        
        let imageName: String
        let title: LocalizedStringKey
    }
    
    private var facts: [Fact] {
        var result = [Fact]()
        
        if let hasVeganFood = item.hasVeganFood {
            result.append(.init(
                imageName: "leaf",
                title:  hasVeganFood.title(mainTitleKey: "itemSheet.facts.vegan")
            ))
        }
        if let hasVegetarianFood = item.hasVegetarianFood {
            result.append(.init(
                imageName: "leaf",
                title: hasVegetarianFood.title(mainTitleKey: "itemSheet.facts.vegetarian")
            ))
        }
        
        if let takeaway = item.takeaway {
            result.append(.init(
                imageName: "takeoutbag.and.cup.and.straw",
                title: takeaway.title(mainTitleKey: "itemSheet.facts.takeaway")
            ))
        }
        if let indoorSeating = item.indoorSeating {
            result.append(.init(
                imageName: "chair",
                title: indoorSeating.title(mainTitleKey: "itemSheet.facts.indoorSeating")
            ))
        }
        if let outdoorSeating = item.outdoorSeating {
            result.append(.init(
                imageName: "sun.max.fill",
                title:  outdoorSeating.title(mainTitleKey: "itemSheet.facts.outdoorSeating")
            ))
        }
        if let smoking = item.smoking {
            result.append(.init(
                imageName: smoking == .yes ? "checkmark.circle" : "nosign",
                title: smoking.title(mainTitleKey: "itemSheet.facts.smoking")
            ))
        }
        
        if let internetAccess = item.internetAccess {
            let fact: Fact?
            
            switch internetAccess {
            case .yes:
                fact = .init(
                    imageName: "wifi",
                    title: "itemSheet.facts.internetAccess"
                )
            case .no:
                fact = .init(
                    imageName: "wifi.slash",
                    title: "itemSheet.facts.internetAccess.no"
                )
            case .wlan:
                fact = .init(
                    imageName: "wifi",
                    title: "itemSheet.facts.internetAccess.wifi"
                )
            case .terminal:
                fact = .init(
                    imageName: "desktopcomputer",
                    title: "itemSheet.facts.internetAccess.terminal"
                )
            case .service:
                fact = nil
            case .wired:
                fact = .init(
                    imageName: "cable.connector",
                    title: "itemSheet.facts.internetAccess.wired"
                )
            }
            
            if let fact {
                result.append(fact)
            }
        }
        
        if let wheelchair = item.wheelchair {
            let fact: Fact
            
            switch wheelchair {
            case .yes:
                fact = .init(
                    imageName: "figure.roll",
                    title: "itemSheet.facts.wheelchair"
                )
            case .no:
                fact = .init(
                    imageName: "exclamationmark.triangle",
                    title: "itemSheet.facts.wheelchair.no"
                )
            case .designated:
                fact = .init(
                    imageName: "figure.roll",
                    title: "itemSheet.facts.wheelchair.designated"
                )
            case .limited:
                fact = .init(
                    imageName: "figure.roll",
                    title: "itemSheet.facts.wheelchair.limited"
                )
            }
            
            result.append(fact)
        }
        
        return result
    }
    
    @ViewBuilder var factsSection: some View {
        let facts = self.facts
        if !facts.isEmpty {
            ListEmulationSection(headerText: "itemSheet.facts") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(facts) { fact in
                            HStack {
                                Image(systemName: fact.imageName)
                                Text(fact.title, bundle: .module)
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding()
            }
        }
    }
}

extension ExclusivityBool {
    func title(mainTitleKey: String) -> LocalizedStringKey {
        let localized = mainTitleKey.moduleLocalized
        switch self {
        case .yes:
            return .init(localized)
        case .no:
            return "itemSheet.facts.no \(localized)"
        case .only:
            return "itemSheet.facts.only \(localized)"
        }
    }
}

extension PlaceBool {
    func title(mainTitleKey: String) -> LocalizedStringKey {
        let localized = mainTitleKey.moduleLocalized
        switch self {
        case .yes:
            return .init(localized)
        case .no:
            return "itemSheet.facts.no \(localized)"
        }
    }
}
