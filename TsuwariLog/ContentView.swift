import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TimelineView()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LogEntry.self, configurations: config)
    return ContentView()
        .modelContainer(container)
}

