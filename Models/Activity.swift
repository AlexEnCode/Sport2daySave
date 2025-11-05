// [Melwic] 29/10 Création de class Activity, 30/10 maj @Model
// [Alex]  3/11 Gestion des coordoné par méthode
// Activity.swift

// Activity.swift
import SwiftUI
import SwiftData
import CoreLocation

@Model
final class Activity: Identifiable {
    @Attribute(.unique) var activityID = UUID()
    
    // Champs
    var activityTitle: String
    var activityLocation: String
    var activityDate: Date
    var activityDescription: String
    var activityPlayers: Int
    
    // Relations
    @Relationship(deleteRule: .nullify)
    var activityOrganizer: User?
    
    @Relationship(deleteRule: .nullify)
    var activityParticipants: [User] = []
    
    // Raw values
    var activitySportRaw: String
    var activityLevelRaw: String
    var activityMindsetRaw: String
    var activityGenderRaw: String
    var activityHandiFriendly: Bool
    
    init(
        title: String,
        location: String,
        date: Date,
        description: String,
        players: Int,
        organizer: User?,
        participants: [User] = [],
        sport: SportType,
        level: LevelType,
        mindset: MindsetType,
        gender: GenderType,
        handiFriendly: Bool
    ) {
        self.activityTitle = title
        self.activityLocation = location
        self.activityDate = date
        self.activityDescription = description
        self.activityPlayers = players
        self.activityOrganizer = organizer
        self.activityParticipants = participants
        self.activitySportRaw = sport.rawValue
        self.activityLevelRaw = level.rawValue
        self.activityMindsetRaw = mindset.rawValue
        self.activityGenderRaw = gender.rawValue
        self.activityHandiFriendly = handiFriendly
    }
    
    // MARK: - Computed Properties
    var sport: SportType {
        get { SportType(rawValue: activitySportRaw) ?? .football }
        set { activitySportRaw = newValue.rawValue }
    }
    
    var level: LevelType {
        get { LevelType(rawValue: activityLevelRaw) ?? .novice }
        set { activityLevelRaw = newValue.rawValue }
    }
    
    var mindset: MindsetType {
        get { MindsetType(rawValue: activityMindsetRaw) ?? .fairplay }
        set { activityMindsetRaw = newValue.rawValue }
    }
    
    var gender: GenderType {
        get { GenderType(rawValue: activityGenderRaw) ?? .tous }
        set { activityGenderRaw = newValue.rawValue }
    }
    
    var handiFriendly: Bool {
        get { activityHandiFriendly }
        set { activityHandiFriendly = newValue }
    }
    
    // MARK: - Géocodage
    func coordinates() async -> CLLocationCoordinate2D? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(activityLocation)
            return placemarks.first?.location?.coordinate
        } catch {
            print("Erreur géolocalisation \(activityLocation): \(error.localizedDescription)")
            return nil
        }
    }
}
