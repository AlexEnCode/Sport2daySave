
// [Alex] 29/10 ATTENTION CEST DU CHNAPS GPT POUR FAIRE DES TESTS DE VIEW
import SwiftUI

struct SportCellView: View {
    var activity: Activity

    //  Computed properties
    private var sport: SportType {
        SportType(rawValue: activity.activitySportRaw) ?? .football
    }

    private var level: LevelType {
        LevelType(rawValue: activity.activityLevelRaw) ?? .novice
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: activity.activityDate)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH'h'mm"
        return formatter.string(from: activity.activityDate)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("containerGray"))
                .shadow(radius: 3)
            
            HStack(spacing: 14) {
                // --- Colonne gauche : icône + niveau
                VStack(spacing: 6) {
                    Image(systemName: sport.icon)
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                    
                    Text(level.displayName.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                }
                .frame(width: 60)
                
                // --- Colonne droite : titre, date, lieu
                VStack(alignment: .leading, spacing: 8) {
                    // Titre et bouton
                    HStack {
                        Text(activity.activityTitle.uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Bouton Détails (à remplacer par ta vue de détails)
                        NavigationLink(destination: Text("Détails de \(activity.activityTitle)")) {
                            Text("DÉTAILS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Color.orange)
                                .cornerRadius(6)
                        }
                    }
                    
                    // Date et heure
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                            .font(.system(size: 14))
                        
                        Text("\(formattedDate) à \(formattedTime)")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }
                    
                    // Lieu
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.orange)
                            .font(.system(size: 14))
                        
                        Text(activity.activityLocation)
                            .foregroundColor(.white)
                            .font(.system(size: 13))
                            .lineLimit(1)
                        
                        Text("│")
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("200m")
                            .foregroundColor(.white)
                            .font(.system(size: 13))
                    }
                }
            }
            .padding(12)
        }
        .frame(maxWidth: 340)
        .frame(height: 100)
    }
}

#Preview {
    let user = User(
        name: "Erika",
        email: "erika@example.com",
        password: "123",
        location: "Lille",
        description: "Passionnée de sport.",
        photo: "erika"
    )

    let activityPreview = Activity(
        title: "Match de basket amical",
        location: "Gymnase Jean Bouin, Lille",
        date: Date(),
        description: "Rencontre conviviale pour débutants.",
        players: 6,
        organizer: user,
        participants: [],
        sport: .basketball,
        level: .novice,
        mindset: .fairplay,
        gender: .tous,
        handiFriendly: true
    )

    return SportCellView(activity: activityPreview)
        .preferredColorScheme(.dark)
        .padding()
        .background(Color.black)
}
