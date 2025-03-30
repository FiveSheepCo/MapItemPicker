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
        case .airport: .airport
        case .amusementPark: .amusementPark
        case .aquarium: .aquarium
        case .atm: .atm
        case .bakery: .bakery
        case .bank: .bank
        case .beach: .beach
        case .brewery: .brewery
        case .cafe: .cafe
        case .campground: .campground
        case .carRental: .carRental
        case .evCharger: .evCharger
        case .fireStation: .fireStation
        case .fitnessCenter: .fitnessCenter
        case .foodMarket: .foodMarket
        case .gasStation: .gasStation
        case .hospital: .hospital
        case .hotel: .hotel
        case .laundry: .laundry
        case .library: .library
        case .marina: .marina
        case .movieTheater: .movieTheater
        case .museum: .museum
        case .nationalPark: .nationalPark
        case .nightlife: .nightlife
        case .park: .park
        case .parking: .parking
        case .pharmacy: .pharmacy
        case .police: .police
        case .postOffice: .postOffice
        case .publicTransport: .publicTransport
        case .restaurant: .restaurant
        case .restroom: .restroom
        case .school: .school
        case .stadium: .stadium
        case .store: .store
        case .theater: .theater
        case .university: .university
        case .winery: .winery
        case .zoo: .zoo
        }
    }
    
    public var id: String { rawValue }
    
    public var name: String {
        "category.\(rawValue)".moduleLocalized
    }
    
    public var circledImageName: String? {
        switch self {
        case .airport:
            return "airplane.circle.fill"
        case .amusementPark:
            return nil // No equivalent for "sparkles.circle.fill"
        case .aquarium:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "fish.circle.fill"
            }
            return "mappin.circle.fill"
        case .atm:
            return "dollarsign.circle.fill"
        case .bakery:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return nil // No equivalent for "birthday.cake.circle.fill"
            }
            return "mappin.circle.fill"
        case .bank:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "person.bust.circle.fill"
            }
            return "dollarsign.circle.fill"
        case .beach:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return nil // No "beach.umbrella.circle.fill"
            }
            return "drop.circle.fill"
        case .brewery:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return nil // No "wineglass.circle.fill"
            }
            return nil
        case .cafe:
            return nil // No "cup.and.saucer.circle.fill"
        case .campground:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return nil // No "tent.circle.fill"
            }
            return nil
        case .carRental:
            return nil // No "car.2.circle.fill"
        case .evCharger:
            return nil // No "powerplug.circle.fill"
        case .fireStation:
            return "flame.circle.fill"
        case .fitnessCenter:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return nil // No "dumbbell.circle.fill"
            }
            return nil
        case .foodMarket:
            return nil // No "basket.circle.fill"
        case .gasStation:
            return "fuelpump.circle.fill"
        case .hospital:
            return "cross.circle.fill"
        case .hotel:
            return "bed.double.circle.fill"
        case .laundry:
                if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                    return "tshirt.circle.fill"
                }
                return nil
        case .library:
            return "books.vertical.circle.fill"
        case .marina:
            return nil // No "ferry.circle.fill"
        case .movieTheater:
            return "theatermasks.circle.fill"
        case .museum:
            return "building.columns.circle.fill"
        case .nationalPark:
            return "star.circle.fill"
        case .nightlife:
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *) {
                return "figure.dance.circle.fill"
            }
            return nil
        case .park:
            if #available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, *) {
                return "tree.circle.fill"
            }
            return "leaf.circle.fill"
        case .parking:
            return "parkingsign.circle.fill"
        case .pharmacy:
            return "pills.circle.fill"
        case .police:
            return "shield.circle.fill"
        case .postOffice:
            return "envelope.circle.fill"
        case .publicTransport:
            return "tram.circle.fill"
        case .restaurant:
            return "fork.knife.circle.fill"
        case .restroom:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "toilet.circle.fill"
            }
            return "mappin.circle.fill"
        case .school:
            return "graduationcap.circle.fill"
        case .stadium:
            return "sportscourt.circle.fill"
        case .store:
            return "bag.circle.fill"
        case .theater:
            return "theatermasks.circle.fill"
        case .university:
            return "graduationcap.circle.fill"
        case .winery:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return nil // No "wineglass.circle.fill"
            }
            return nil // No "takeoutbag.and.cup.and.straw.fill"
        case .zoo:
            return nil // No "tortoise.circle.fill"
        }
    }
    
    public var imageName: String {
        switch self {
        case .airport:
            return "airplane"
        case .amusementPark:
            return "sparkles"
        case .aquarium:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "fish.fill"
            }
            return "mappin"
        case .atm:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "dollarsign"
            }
            return "dollarsign.circle.fill"
        case .bakery:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "birthday.cake"
            }
            return "mappin"
        case .bank:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "person.bust.fill"
            }
            return "dollarsign.circle.fill"
        case .beach:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "beach.umbrella.fill"
            }
            return "drop.fill"
        case .brewery:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "wineglass.fill"
            }
            return "takeoutbag.and.cup.and.straw.fill"
        case .cafe:
            return "cup.and.saucer.fill"
        case .campground:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "tent.fill"
            }
            return "powersleep"
        case .carRental:
            return "car.2.fill"
        case .evCharger:
            return "powerplug.fill"
        case .fireStation:
            return "flame.fill"
        case .fitnessCenter:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "dumbbell.fill"
            }
            return "sportscourt.fill"
        case .foodMarket:
            return "basket.fill"
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
            return "theatermasks.fill"
        case .museum:
            return "building.columns.fill"
        case .nationalPark:
            return "star.fill"
        case .nightlife:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "figure.dance"
            }
            return "takeoutbag.and.cup.and.straw.fill"
        case .park:
            if #available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, *) {
                return "tree.fill"
            }
            return "leaf.fill"
        case .parking:
            return "parkingsign"
        case .pharmacy:
            return "pills.fill"
        case .police:
            return "shield.fill"
        case .postOffice:
            return "envelope.fill"
        case .publicTransport:
            return "tram.fill"
        case .restaurant:
            return "fork.knife"
        case .restroom:
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "toilet.fill"
            }
            return "mappin"
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
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                return "wineglass.fill"
            }
            return "takeoutbag.and.cup.and.straw.fill"
        case .zoo:
            return "tortoise.fill"
        }
    }
    
    public var color: UIColor {
        switch self {
            case .bakery, .brewery, .cafe, .restaurant, .nightlife:
                return .systemOrange
            case .laundry, .foodMarket, .store:
                return .systemYellow
            case .amusementPark, .aquarium, .movieTheater, .museum, .theater, .winery, .zoo:
                return .systemPink
            case .atm, .bank, .carRental, .police, .postOffice:
                return .systemGray
            case .fitnessCenter, .beach, .marina:
                return .systemCyan
            case .airport, .gasStation, .parking, .publicTransport:
                return .systemBlue
            case .evCharger:
                return .systemMint
            case .campground, .nationalPark, .park, .stadium:
                return .systemGreen
            case .fireStation, .hospital, .pharmacy:
                return .systemRed
            case .hotel, .restroom:
                return .systemPurple
            case .library, .school, .university:
                return .systemBrown
        }
    }
}
