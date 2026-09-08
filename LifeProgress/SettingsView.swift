import SwiftUI
import CloudKit
import LifeProgressShared

struct SettingsView: View {
    @State private var expectedAge: Int = 80
    @State private var birthday: Date = Date()
    @State private var livedColor: Color = Color(hex: "26C281")
    @State private var unlivedColor: Color = Color(hex: "E0E0E0")

    private let colorPresets: [Color] = [
        Color(hex: "26C281"), // emerald
        Color(hex: "3A7BD5"), // ocean blue
        Color(hex: "E55934"), // coral
        Color(hex: "F39C12"), // amber
        Color(hex: "8E44AD"), // violet
        Color(hex: "E84393"), // rose
        Color(hex: "00B894"), // teal
        Color(hex: "6C5CE7"), // indigo
    ]

    private let grayPresets: [Color] = [
        Color(hex: "E0E0E0"), // light gray
        Color(hex: "BDBDBD"), // medium gray
        Color(hex: "9E9E9E"), // dark gray
        Color(hex: "ECEFF1"), // blue gray
        Color(hex: "F5F0E8"), // warm gray
    ]

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

            Section(header: Text("Lived Color"), footer: Text("Color for time periods you have already lived.")) {
                HStack(spacing: 10) {
                    ForEach(colorPresets, id: \.self) { preset in
                        Circle()
                            .fill(preset)
                            .frame(width: 28, height: 28)
                            .overlay {
                                if livedColor.hexString == preset.hexString {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .onTapGesture { livedColor = preset }
                    }
                }
                .onChange(of: livedColor) { newValue in
                    let hex = newValue.hexString
                    NSUbiquitousKeyValueStore.default.set(hex, forKey: "livedColor")
                    NSUbiquitousKeyValueStore.default.synchronize()
                    UserDefaults(suiteName: "group.com.v2free.life_progress")?.set(hex, forKey: "livedColor")
                }
            }

            Section(header: Text("Unlived Color"), footer: Text("Color for time periods yet to come.")) {
                HStack(spacing: 10) {
                    ForEach(grayPresets, id: \.self) { preset in
                        Circle()
                            .fill(preset)
                            .frame(width: 28, height: 28)
                            .overlay {
                                if unlivedColor.hexString == preset.hexString {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                            }
                            .onTapGesture { unlivedColor = preset }
                    }
                }
                .onChange(of: unlivedColor) { newValue in
                    let hex = newValue.hexString
                    NSUbiquitousKeyValueStore.default.set(hex, forKey: "unlivedColor")
                    NSUbiquitousKeyValueStore.default.synchronize()
                    UserDefaults(suiteName: "group.com.v2free.life_progress")?.set(hex, forKey: "unlivedColor")
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
            let savedLived = store.string(forKey: "livedColor") ?? "26C281"
            livedColor = Color(hex: savedLived)
            let savedUnlived = store.string(forKey: "unlivedColor") ?? "E0E0E0"
            unlivedColor = Color(hex: savedUnlived)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
