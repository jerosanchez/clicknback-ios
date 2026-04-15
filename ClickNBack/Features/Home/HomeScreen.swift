//

import SwiftUI

struct HomeScreen: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            OffersScreen()
                .tabItem {
                    Label("Offers", systemImage: "tag.fill")
                }
                .tag(0)

            PurchasesScreen()
                .tabItem {
                    Label("Purchases", systemImage: "bag.fill")
                }
                .tag(1)

            WalletScreen()
                .tabItem {
                    Label("Wallet", systemImage: "wallet.pass.fill")
                }
                .tag(2)

            ProfileScreen()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

#Preview {
    HomeScreen()
}
