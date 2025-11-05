
// [Alex] 29/10  récupération de mes tests mapKit
// Ajout des Cell
// SearchCellView fonctionnel uniquement pour l'adresse
// Map début
// La bar de recherche n'est pas encré
//[Alex] 03/11 Tout les élléménets sont fonctinelle, ajout du bouton creatActivity
// [Alex] 04/11 bouton create activity fonctionnelle


import SwiftUI
import MapKit
import SwiftData
import CoreLocation

struct MapView: View {
    //  Environment & Données
    @Environment(\.modelContext) private var context
    @Query(sort: \Activity.activityDate) private var activities: [Activity]
    
  
    @State private var selectedActivity: Activity?
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.6292, longitude: 3.0573), // Lille
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    @State private var showActivityPopup = false
    @State private var showFilterPopup = false
    @State private var showListView = false
    @State private var showCreateActivity = false
    
    @State private var searchText = ""
    @State private var filters = SearchFilters.empty
    @Namespace private var animation
    @State private var refreshID = UUID()
    @State private var isSearching = false
    
    // MARK: - Géocodage
    private func geocodeAndMove(to address: String) async {
        await MainActor.run { isSearching = true }
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            if let location = placemarks.first?.location {
                let coordinate = location.coordinate
                withAnimation(.easeInOut) {
                    position = .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                        )
                    )
                }
            }
        } catch {
            print("❌ Erreur géocodage : \(error.localizedDescription)")
        }
        await MainActor.run { isSearching = false }
    }
    
    // Corps principal
    var body: some View {
        ZStack {
            Color("bluePrimary").ignoresSafeArea()
            
            VStack(spacing: 12) {
                // --- Barre supérieure ---
                VStack(spacing: 8) {
                    // Champ de recherche
                    Button {
                        showFilterPopup = true
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.9))
                            Text(searchText.isEmpty ? "Rechercher une activité" : searchText)
                                .foregroundColor(.white.opacity(0.9))
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .frame(height: 42)
                        .background(Color("containerGray"))
                        .cornerRadius(10)
                    }
                    
                    // --- Switch Carte / Liste ---
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("containerGray"))
                        
                        HStack(spacing: 0) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) { showListView = false }
                            } label: {
                                Text("Carte")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(
                                        Group {
                                            if !showListView {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.orangePrimary)
                                                    .matchedGeometryEffect(id: "tab", in: animation)
                                            }
                                        }
                                    )
                                    .foregroundColor(!showListView ? .white : .white.opacity(0.7))
                            }
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) { showListView = true }
                            } label: {
                                Text("Liste")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(
                                        Group {
                                            if showListView {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.orangePrimary)
                                                    .matchedGeometryEffect(id: "tab", in: animation)
                                            }
                                        }
                                    )
                                    .foregroundColor(showListView ? .white : .white.opacity(0.7))
                            }
                        }
                        .padding(4)
                    }
                    .frame(height: 44)
                }
                .padding(.top, 30)
                .padding(.horizontal, 16)
                
                // --- Carte ou Liste ---
                if showListView {
                    ActivityListCellView(activities: filteredActivities)
                        .transition(.opacity)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 16)
                } else {
                    MapCellView(
                        position: $position,
                        activities: filteredActivities,
                        selectedActivity: $selectedActivity
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    .transition(.opacity)
                }
            }
            
            // --- Bouton flottant (+) ---
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showCreateActivity = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.orangePrimary)
                            .padding(20)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .overlay(Circle().stroke(Color.orangePrimary.opacity(0.9), lineWidth: 1))
                            )
                            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                    }
                    .padding(.trailing, 22)
                    .padding(.bottom, 32)
                }
            }
            
            // --- Popup Activité ---
            if showActivityPopup, let selected = selectedActivity {
                VStack {
                    Spacer()
                    ActivityInfoPopUpCellView(activity: selected) {
                        withAnimation(.spring()) {
                            showActivityPopup = false
                            selectedActivity = nil
                        }
                    }
                    .padding(.horizontal, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        
        //  Événements
        .onReceive(NotificationCenter.default.publisher(for: .activityCreated)) { _ in
            refreshID = UUID()
        }
        .id(refreshID)
        
        //  Pop-up filtres
        .sheet(isPresented: $showFilterPopup) {
            SearchFilterPopUpView(searchText: $searchText) { newFilters in
                print("🔎 Filtres reçus :", newFilters)
                filters = newFilters
                if !newFilters.searchText.isEmpty {
                    Task { await geocodeAndMove(to: newFilters.searchText) }
                }
            }
        }
        
        // Pop-up création
        .sheet(isPresented: $showCreateActivity) {
            CreateActivityView()
        }
    }
    
    // Filtrage
    private var filteredActivities: [Activity] {
        activities.filter { activity in
            var matches = true
            
            // 1. Ville
            if !filters.searchText.isEmpty {
                let search = filters.searchText.lowercased()
                matches = activity.activityLocation.lowercased().contains(search)
            }
            
            // j'ai des bug, on ne filtre que par la ville pour l'instant
   
            // 2. Sport
            if !filters.sports.isEmpty {
                matches = matches && filters.sports.contains(activity.sport.rawValue)
            }
            
            /*
            // 3. Niveau
            if filters.level != "TOUS" {
                matches = matches && activity.level.rawValue == filters.level
            }

             
            // 4. Participants
            matches = matches && activity.activityPlayers >= filters.participantsMin &&
                      activity.activityPlayers <= filters.participantsMax
          

            // 5. Dates
            if let start = filters.dateStart {
                matches = matches && activity.activityDate >= start
            }
            if let end = filters.dateEnd {
                matches = matches && activity.activityDate <= end
            }
    */
            
            return matches
        }
    }
}

// oins arrondis (CORRIGÉ)
fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

fileprivate struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
