import SwiftUI
import CloudKit

struct SettingsView: View {
    @State private var expectedAge: Int = 80
    @State private var birthday: Date = Date()
    
    var body: some View {
        Form {
            Section(header: Text("Expected Age")) {
                Stepper(value: $expectedAge, in: 0...150) {
                    Text("\(expectedAge) years")
                }
                .onChange(of: expectedAge) { newValue in
                    let store = NSUbiquitousKeyValueStore.default
                    store.set(newValue, forKey: "expectedAge")
                    store.synchronize()
                    let defaults = UserDefaults(suiteName: "group.com.v2free.life_progress")
                    defaults?.set(expectedAge, forKey: "expectedAge")

                }
            }
            
            Section(header: Text("Birthday")) {
                DatePicker("Select your birthday", selection: $birthday, displayedComponents: .date)
                    .onChange(of: birthday) { newValue in
                        let store = NSUbiquitousKeyValueStore.default
                        store.set(newValue.timeIntervalSince1970, forKey: "birthday")
                        store.synchronize()
                        let defaults = UserDefaults(suiteName: "group.com.v2free.life_progress")
                        defaults?.set(newValue.timeIntervalSince1970, forKey: "birthday")
                    }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            let store = NSUbiquitousKeyValueStore.default
            if store.longLong(forKey: "expectedAge") == 0 {
                expectedAge = 80
            } else {
                expectedAge = Int(store.longLong(forKey: "expectedAge")) as Int
            }
            if store.double(forKey: "birthday") == 0 {
                birthday = Date(timeIntervalSince1970: 946684800)
            } else {
                birthday = Date(timeIntervalSince1970: store.double(forKey: "birthday"))
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
