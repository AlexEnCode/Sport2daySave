// [Melwic] 29/10 Création de class User, 30/10 maj @Model


import Foundation
import SwiftData


@Model
class User: Identifiable {
    @Attribute(.unique) var userID = UUID()
    
    var userName: String
    var userEmail: String
    var userPassword: String
    
    // relations inverses — noms alignés avec Activity
    @Relationship(inverse: \Activity.activityOrganizer)
    var userCreatedActivities: [Activity] = []
    
    @Relationship(inverse: \Activity.activityParticipants)
    var userJoinedActivities: [Activity] = []
    
    // autres propriétés utilisateur
    var userLocation: String
    var userDescription: String
    var userPhoto: String
    
    init(
        name: String,
        email: String,
        password: String,
        location: String,
        description: String,
        photo: String
    ) {
        self.userName = name
        self.userEmail = email
        self.userPassword = password
        self.userLocation = location
        self.userDescription = description
        self.userPhoto = photo
    }
}
