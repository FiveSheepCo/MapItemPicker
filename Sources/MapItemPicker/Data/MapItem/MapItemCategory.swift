import MapKit
import SwiftUI

public enum MapItemCategory: String, Codable, CaseIterable, Identifiable {
    case airport, amusementPark, aquarium, atm, bakery, bank, beach, brewery, cafe, campground, carRental, evCharger, fireStation, fitnessCenter, foodMarket, gasStation, hospital, hotel, laundry, library, marina, movieTheater, museum, nationalPark, nightlife, park, parking, pharmacy, police, postOffice, publicTransport, restaurant, restroom, school, stadium, store, theater, university, winery, zoo
    
    init?(nativeCategory: MKPointOfInterestCategory) {
        switch nativeCategory {
        case .airport:
            self = .airport
        case .amusementPark:
            self = .amusementPark
        case .aquarium:
            self = .aquarium
        case .atm:
            self = .atm
        case .bakery:
            self = .bakery
        case .bank:
            self = .bank
        case .beach:
            self = .beach
        case .brewery:
            self = .brewery
        case .cafe:
            self = .cafe
        case .campground:
            self = .campground
        case .carRental:
            self = .carRental
        case .evCharger:
            self = .evCharger
        case .fireStation:
            self = .fireStation
        case .fitnessCenter:
            self = .fitnessCenter
        case .foodMarket:
            self = .foodMarket
        case .gasStation:
            self = .gasStation
        case .hospital:
            self = .hospital
        case .hotel:
            self = .hotel
        case .laundry:
            self = .laundry
        case .library:
            self = .library
        case .marina:
            self = .marina
        case .movieTheater:
            self = .movieTheater
        case .museum:
            self = .museum
        case .nationalPark:
            self = .nationalPark
        case .nightlife:
            self = .nightlife
        case .park:
            self = .park
        case .parking:
            self = .parking
        case .pharmacy:
            self = .pharmacy
        case .police:
            self = .police
        case .postOffice:
            self = .postOffice
        case .publicTransport:
            self = .publicTransport
        case .restaurant:
            self = .restaurant
        case .restroom:
            self = .restroom
        case .school:
            self = .school
        case .stadium:
            self = .stadium
        case .store:
            self = .store
        case .theater:
            self = .theater
        case .university:
            self = .university
        case .winery:
            self = .winery
        case .zoo:
            self = .zoo
        default:
            return nil
        }
    }
    
    var nativeCategory: MKPointOfInterestCategory {
        switch self {
        case .airport:
            return .airport
        case .amusementPark:
            return .amusementPark
        case .aquarium:
            return .aquarium
        case .atm:
            return .atm
        case .bakery:
            return .bakery
        case .bank:
            return .bank
        case .beach:
            return .beach
        case .brewery:
            return .brewery
        case .cafe:
            return .cafe
        case .campground:
            return .campground
        case .carRental:
            return .carRental
        case .evCharger:
            return .evCharger
        case .fireStation:
            return .fireStation
        case .fitnessCenter:
            return .fitnessCenter
        case .foodMarket:
            return .foodMarket
        case .gasStation:
            return .gasStation
        case .hospital:
            return .hospital
        case .hotel:
            return .hotel
        case .laundry:
            return .laundry
        case .library:
            return .library
        case .marina:
            return .marina
        case .movieTheater:
            return .movieTheater
        case .museum:
            return .museum
        case .nationalPark:
            return .nationalPark
        case .nightlife:
            return .nightlife
        case .park:
            return .park
        case .parking:
            return .parking
        case .pharmacy:
            return .pharmacy
        case .police:
            return .police
        case .postOffice:
            return .postOffice
        case .publicTransport:
            return .publicTransport
        case .restaurant:
            return .restaurant
        case .restroom:
            return .restroom
        case .school:
            return .school
        case .stadium:
            return .stadium
        case .store:
            return .store
        case .theater:
            return .theater
        case .university:
            return .university
        case .winery:
            return .winery
        case .zoo:
            return .zoo
        }
    }
    
    public var id: String { rawValue }
    
    var name: String {
        "category.\(rawValue)".moduleLocalized
    }
    
    var imageName: String {
        switch self {
        case .airport:
            return "airplane"
        case .amusementPark:
            return "sparkles"
        case .aquarium:
            return "fish.fill"
        case .atm:
            return "dollarsign"
        case .bakery:
            return "birthday.cake"
        case .bank:
            return "person.bust.fill"
        case .beach:
            return "beach.umbrella.fill"
        case .brewery:
            return "wineglass.fill"
        case .cafe:
            return "cup.and.saucer.fill"
        case .campground:
            return "tent.fill"
        case .carRental:
            return "car.2.fill"
        case .evCharger:
            return "powerplug.fill"
        case .fireStation:
            return "flame.fill"
        case .fitnessCenter:
            return "dumbbell.fill"
        case .foodMarket:
            return "fork.knife"
        case .gasStation:
            return "fuelpump.fill"
        case .hospital:
            return "cross.fill"
        case .hotel:
            return "bed.double.fill"
        case .laundry:
            return "tshirt.fill"
        case .library:
            return "books.vertical.fill"
        case .marina:
            return "ferry.fill"
        case .movieTheater:
            return "popcorn.fill"
        case .museum:
            return "building.columns.fill"
        case .nationalPark:
            return "star.fill"
        case .nightlife:
            return "figure.dance"
        case .park:
            return "tree.fill"
        case .parking:
            return "parkingsign"
        case .pharmacy:
            return "pill.fill"
        case .police:
            return "shield.fill"
        case .postOffice:
            return "envelope.fill"
        case .publicTransport:
            return "tram.fill"
        case .restaurant:
            return "fork.knife"
        case .restroom:
            return "toilet.fill"
        case .school:
            return "graduationcap.fill"
        case .stadium:
            return "sportscourt.fill"
        case .store:
            return "bag.fill"
        case .theater:
            return "theatermasks.fill"
        case .university:
            return "graduationcap.fill"
        case .winery:
            return "wineglass.fill"
        case .zoo:
            return "tortoise.fill"
        }
    }
    
    var color: UIColor {
        switch self {
        case .bakery, .brewery, .cafe, .foodMarket, .laundry, .nightlife, .store:
            return .orange
        case .amusementPark, .aquarium, .movieTheater, .museum, .restaurant, .theater, .winery, .zoo:
            return .systemPink
        case .atm, .bank, .carRental, .police, .postOffice:
            return .gray
        case .airport, .fitnessCenter, .gasStation, .parking, .publicTransport, .beach, .marina:
            return .init(red: 0.33, green: 0.33, blue: 1) // lightblue
        case .campground, .evCharger, .nationalPark, .park, .stadium:
            return .init(red: 0, green: 0.75, blue: 0) // darkgreen
        case .fireStation, .hospital, .pharmacy:
            return .red
        case .hotel, .restroom:
            return .purple
        case .library, .school, .university:
            return .brown
        }
    }
}
