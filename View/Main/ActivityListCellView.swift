// [Alex]  30/10 Attention, code généré pour tests

import SwiftUI

struct ActivityListCellView: View {
    let activities: [Activity]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(activities) { activity in
                    SportCellView(activity: activity)
                }
            }
            .padding()
        }
    }
}
