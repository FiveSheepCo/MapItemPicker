import SwiftUI
import SchafKit

struct SearchSheet<SearchView: View>: View {
    @ObservedObject var coordinator: MapItemPickerController
    @ObservedObject var searcher: MapItemSearchController
    
    let dismissHandler: (() -> Void)?
    let standardView: () -> SearchView
    
    @available(iOS 15.0, *)
    struct SearchField: View {
        @ObservedObject var searcher: MapItemSearchController
        @FocusState private var searchFieldIsFocused: Bool
        
        let foregroundColor: Color
        
        var body: some View {
            TextField(text: $searcher.searchTerm) {
                Text("search", bundle: Bundle.module).foregroundColor(foregroundColor)
            }
            .focused($searchFieldIsFocused)
            Button {
                searcher.searchTerm = .empty
                searchFieldIsFocused = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(foregroundColor)
            }
            .opacity(searcher.searchTerm.isEmpty ? 0 : 1)
        }
    }
    
    @ViewBuilder var filters: some View {
        if #available(iOS 14, *) {
            HStack {
                Menu {
                    if !searcher.filteredCategories.isEmpty {
                        ForEach(searcher.filteredCategories) { category in
                            Button {
                                searcher.filteredCategories.remove(object: category)
                            } label: {
                                Image(systemName: category.imageName)
                                Text("✓　" + category.name)
                            }
                        }
                        Divider()
                    }
                    ForEach(MapItemCategory.allCases) { category in
                        if !searcher.filteredCategories.contains(category) {
                            Button {
                                searcher.filteredCategories.append(category)
                            } label: {
                                Image(systemName: category.imageName)
                                Text("　　" + category.name)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("search.categories", bundle: .module)
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(searcher.filteredCategories.isEmpty ? Color.gray.opacity(0.5) : Color.accentColor.opacity(0.5))
                    .cornerRadius(.greatestFiniteMagnitude)
                }
                if !searcher.filteredCategories.isEmpty {
                    Button {
                        searcher.clearFilters()
                    } label: {
                        HStack {
                            Text("search.clearFilters", bundle: .module)
                            Image(systemName: "xmark.circle.fill")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.5))
                        .cornerRadius(.greatestFiniteMagnitude)
                    }
                }
                Spacer()
            }
            .textCase(nil)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                HStack(spacing: 2) {
                    let mildColor = Color.label.opacity(0.75)
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(mildColor)
                    if #available(iOS 15, *) {
                        SearchField(searcher: searcher, foregroundColor: mildColor)
                    } else {
                        TextField("search".moduleLocalized, text: $searcher.searchTerm)
                        Button {
                            searcher.searchTerm = .empty
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(mildColor)
                        }
                        .opacity(searcher.searchTerm.isEmpty ? 0 : 1)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .background(Color.secondarySystemGroupedBackground)
                .cornerRadius(6)
                if let dismissHandler {
                    Button {
                        dismissHandler()
                        searcher.searchTerm = .empty
                        searcher.clearFilters()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding([.top, .horizontal])
            ZStack {
                standardView()
                    .environmentObject(coordinator)
                    .opacity(searcher.isNoSearch ? 1 : 0)
                if !searcher.isNoSearch {
                    List {
                        Section {
                            ForEach(searcher.completions.sliced(upTo: 2)) { item in
                                SearchCell(
                                    systemImageName: "magnifyingglass",
                                    color: .gray,
                                    title: item.title,
                                    subtitle: item.subtitle
                                ) {
                                    searcher.search(with: item)
                                }
                            }
                            ForEach(searcher.items) { itemCoordinator in
                                let item = itemCoordinator.item
                                SearchCell(
                                    systemImageName: item.imageName,
                                    color: item.color,
                                    title: item.name,
                                    subtitle: item.subtitle
                                ) {
                                    coordinator.manuallySet(selectedMapItem: itemCoordinator)
                                }
                            }
                        } header: {
                            VStack {
                                filters.padding(.horizontal, -16)
                                HStack {
                                    Text("search.results", bundle: .module)
                                    Spacer()
                                    if searcher.isAnySearching {
                                        if #available(iOS 14.0, *) {
                                            ProgressView()
                                        } else {
                                            Text("search.loading", bundle: .module)
                                        }
                                    }
                                }
                                .frame(minHeight: 18)
                            }
                        }
                        let moreSuggestions = searcher.completions.sliced(upFrom: 2)
                        if !moreSuggestions.isEmpty {
                            Section {
                                ForEach(moreSuggestions) { item in
                                    SearchCell(
                                        systemImageName: "magnifyingglass",
                                        color: .gray,
                                        title: item.title,
                                        subtitle: item.subtitle
                                    ) {
                                        searcher.search(with: item)
                                    }
                                }
                            } header: {
                                Text("search.moreSuggestions", bundle: .module)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.systemGroupedBackground)
        .onDisappear {
            if dismissHandler == nil {
                coordinator.currentMainController?.dismiss(animated: true)
            }
        }
    }
}
