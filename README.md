# MapItemPicker 🗺️📍

[![GithubCI_Status]][GithubCI_URL]
[![FiveSheep_Badge]](https://fivesheep.co)
[![LICENSE_BADGE]][LICENSE_URL]

MapItemPicker is a simple, yet highly customizable and powerful location picker for SwiftUI.

<p float="left">
  <img src="https://user-images.githubusercontent.com/31473326/230954413-98d3428c-69d2-4273-9d49-d0e032fb7173.png" width="200" alt="Sheet for New York City" />
  <img src="https://user-images.githubusercontent.com/31473326/230954539-8d2efe0c-7762-4572-b805-24c383c57ab7.png" width="200" alt="Search for Airport in Germany" /> 
  <img src="https://user-images.githubusercontent.com/31473326/230954579-8c47e8ce-1d57-4623-a6de-c615a0dd5c82.png" width="200" alt="Sheet for Central Park" />
  <img src="https://user-images.githubusercontent.com/31473326/233777851-dc26c6eb-41b4-404e-a9b0-2cf41b967f35.png" width="200" alt="Picker Inside a Full Screen Overlay" />
</p>

## Description

A lot of apps need some kind of view to find and select locations. Sadly, Apple doesn't offer a view for this in their frameworks and a lot of the information displayed in the Maps app that makes it easy to search for and discover map items is not exposed on `MKMapItem`. MapItemPicker uses data from MapKit, OpenStreetMaps and Wikidata to deliver a simple yet beautiful and comprehensive map item picker.

## Example Code

### Simple Picker

#### Convenience Method
```Swift
.mapItemPickerSheet(isPresented: $showsSheet) { mapItem in
    print("Map Item:", mapItem)
}
```

#### Customizable View
```Swift
.fullScreenCover(isPresented: $showsSheet) {
    NavigationView {
        MapItemPicker(
            primaryMapItemAction: .init(
                title: "select",
                imageName: "checkmark.circle.fill",
                handler: { mapItem in
                    print("Map Item:", mapItem)
                    return true
                }
            )
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("cancel") {
                    showsSheet = false
                }
            }
        }
        .navigationTitle(Text("select"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
```

### Advanced Map View with Configured Standard View

```Swift
MapItemPicker(
    annotations: [MKPointAnnotation.chicago],
    annotationView: { annotation in
        MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
    },
    annotationSelectionHandler: { annotation in
        print("selected:", annotation)
    },
    overlays: [MKPolyline.newYorkToLosAngeles],
    overlayRenderer: { overlay in
        MKPolylineRenderer(polyline: overlay as! MKPolyline, color: .red)
    },
    primaryMapItemAction: .init(title: "select", imageName: "checkmark.circle.fill", handler: { mapItem in
        print("Map Item:", mapItem)
        return true
    }),
    additionalMapItemActions: [
        .init(
            title: "addTo",
            imageName: "plus.square",
            subActions: [
                .init(title: "Collection A", imageName: "square.on.square", handler: { mapItem in return false }),
                .init(title: "Collection B", imageName: "square.on.square", handler: { mapItem in return false })
            ]
        )
    ],
    showsLocationButton: false,
    additionalTopRightButtons: [
        .init(
            imageName: "magnifyingglass",
            handler: { searchControllerShown = true }
        )
    ],
    initialRegion: MKCoordinateRegion.unitedStates,
    standardView: { Text("Standard View") },
    searchControllerShown: $searchControllerShown,
    standardSearchView: { Text("Search View") }
)
```

## Localization

MapItemPicker contains localizations for categories, titles of sections in the views and other strings. Currently, only English and German are supported. If you can provide localization for any other language, please submit a PR. You can copy the strings from the English `Localizable.strings` file at `Sources/MapItemPicker/Resources/en.lproj`. It's not a lot of localization keys, you will propably be done in 5 minutes.

## TODO

- [ ] A lot of MapItems currently have a type of simply 'Location' (Localization Key 'mapItem.type.item') before loading Wikidata and/or OpenStreetMaps data. This includes cities, mountains and other items for which Apple doesn't provide a `MKPointOfInterestCategory` and should be resolved.
- [ ] Add more datasources. This can be free ones like Wikidata and OpenStreetMaps, as well as paid ones for which each application can provide their own API key.
- [ ] Add the ability to edit opening hours etc. and report back to OpenStreetMaps
- [ ] Add more filters like "Is Open" in Search
- [ ] Add Unit Tests
- [ ] Add example App with UI Tests
- [ ] Compile Documentation

<!-- References -->

[GithubCI_Status]: https://github.com/FiveSheepCo/MapItemPicker/actions/workflows/ci.yml/badge.svg?branch=main
[GithubCI_URL]: https://github.com/FiveSheepCo/MapItemPicker/actions/workflows/ci.yml
[FiveSheep_Badge]: https://badgen.net/badge/Built%20and%20maintained%20by/FiveSheep/cyan
[LICENSE_BADGE]: https://badgen.net/github/license/FiveSheepCo/MapItemPicker
[LICENSE_URL]: https://github.com/FiveSheepCo/MapItemPicker/blob/master/LICENSE
