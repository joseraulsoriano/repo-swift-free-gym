import SwiftUI
#if os(macOS)
import AppKit
#endif

struct FooterView: View {
    @Binding var selectedTab: Tab
    
    enum Tab {
        case home, settings, routine
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                selectedTab = .home
            }) {
                Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(selectedTab == .home ? .blue : .gray)
            }
            Spacer()
            Button(action: {
                selectedTab = .routine
            }) {
                Image(systemName: selectedTab == .routine ? "flame.fill" : "flame")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(selectedTab == .routine ? .blue : .gray)
            }
            Spacer()
            Button(action: {
                selectedTab = .settings
            }) {
                Image(systemName: selectedTab == .settings ? "gearshape.fill" : "gearshape")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(selectedTab == .settings ? .blue : .gray)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        #if os(iOS)
        .background(Color(UIColor.systemGroupedBackground))
        #else
        .background(Color(NSColor.controlBackgroundColor))
        #endif
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}

#Preview {
    FooterView(selectedTab: .constant(.home))
}
