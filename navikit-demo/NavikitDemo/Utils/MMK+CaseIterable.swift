//
//  MMK+CaseIterable.swift
//

import MappableMobile

extension MMKRoadEventsEventTag: CaseIterable {
    public static var allCases: [MMKRoadEventsEventTag] {
        [
            .accident,
            .chat,
            .closed,
            .crossRoadControl,
            .crossRoadDanger,
            .danger,
            .drawbridge,
            .feedback,
            .laneControl,
            .localChat,
            .mobileControl,
            .noStoppingControl,
            .other,
            .overtakingDanger,
            .pedestrianDanger,
            .police,
            .reconstruction,
            .roadMarkingControl,
            .school,
            .speedControl,
            .trafficAlert
        ]
    }
}

extension MMKDrivingVehicleType: CaseIterable {
    public var description: String {
        switch self {
        case .default:
            return "default"
        case .moto:
            return "moto"
        case .taxi:
            return "taxi"
        case .truck:
            return "truck"
        @unknown default:
            print("Unknown vehicle type - \(self)")
            return "default"
        }
    }

    public static var allCases: [MMKDrivingVehicleType] {
        [
            .default,
            .moto,
            .taxi,
            .truck
        ]
    }
}

extension MMKAnnotationLanguage: CaseIterable {
    public var description: String {
        switch self {
        case .russian:
            return "russian"
        case .english:
            return "english"
        case .french:
            return "french"
        case .turkish:
            return "turkish"
        case .ukrainian:
            return "ukrainian"
        case .italian:
            return "italian"
        case .hebrew:
            return "hebrew"
        case .serbian:
            return "serbian"
        case .latvian:
            return "latvian"
        case .finnish:
            return "finnish"
        case .romanian:
            return "romanian"
        case .kyrgyz:
            return "kyrgyz"
        case .kazakh:
            return "kazakh"
        case .lithuanian:
            return "lithuanian"
        case .estonian:
            return "estonian"
        case .georgian:
            return "georgian"
        case .uzbek:
            return "uzbek"
        case .armenian:
            return "armenian"
        case .azerbaijani:
            return "azerbaijani"
        case .tatar:
            return "tatar"
        case .arabic:
            return "arabic"
        case .portuguese:
            return "portuguese"
        case .latinAmericanSpanish:
            return "es-419"
        @unknown default:
            print("Unknown language - \(self)")
            return String()
        }
    }

    public static var allCases: [MMKAnnotationLanguage] {
        [
            .russian,
            .english,
            .french,
            .turkish,
            .ukrainian,
            .italian,
            .hebrew,
            .serbian,
            .latvian,
            .finnish,
            .romanian,
            .kyrgyz,
            .kazakh,
            .lithuanian,
            .estonian,
            .georgian,
            .uzbek,
            .armenian,
            .azerbaijani,
            .tatar,
            .arabic,
            .portuguese
        ]
    }
}
