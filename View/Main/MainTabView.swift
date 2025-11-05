import SwiftUI
import SwiftData



struct MainTabView: View {
    @Query(sort: \Activity.activityDate, order: .reverse) private var activities: [Activity]

    var body: some View {
        TabView {
            MapView()
                .tabItem { Label("Carte", systemImage: "mappin.circle.fill") }
            
     //       ActivityListCellView()
            MapView()
                .tabItem { Label("Activités", systemImage: "book.fill") }
            
        ErikaProfileView()
  
                .tabItem { Label("Profil", systemImage: "person.crop.circle") }
        }
        .tint(.orangePrimary)
    }
}



