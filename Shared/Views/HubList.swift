//
//  HubList.swift
//  WICRS Client
//
//  Created by Willem on 2022-01-20.
//

import SwiftUI

struct HubList: View {
    @Binding var hubs: [UUIDString:Hub]
    @State private var joinID = ""
    
    var body: some View {
        NavigationView {
            List($hubs.values.sorted { $0.name.wrappedValue.compare($1.name.wrappedValue, options: [.caseInsensitive, .numeric]) == ComparisonResult.orderedAscending }) { hub in
                NavigationLink {
                    HubView(hub: hub)
                } label: {
                    HubRow(hub: hub)
                }
            }.navigationTitle("Hubs").listStyle(.sidebar)
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        TextField("Join Hub", text: $joinID).onSubmit(onJoin)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: onAdd) { Image(systemName: "plus") }
                    }
                    #else
                    Button(action: onAdd) { Image(systemName: "plus") }
                    #endif
                }
        }
    }
    
    private func onAdd() {
        if let new_hub_id = try? WICRSClient.http_client.create_hub(name: "New Hub", description: "A new hub.") {
            hubs[new_hub_id] = try? HubLoader.shared.loadHubSubscribe(new_hub_id)
            var in_hubs = AppConfig.hubs
            in_hubs.append(new_hub_id)
            AppConfig.hubs = in_hubs
        }
    }
    
    private func onJoin() {
        if (try? WICRSClient.http_client.join_hub(hub_id: joinID)) != nil {
            hubs[joinID] = try? HubLoader.shared.loadHubSubscribe(joinID)
            var in_hubs = AppConfig.hubs
            in_hubs.append(joinID)
            AppConfig.hubs = in_hubs
        }
        joinID = ""
    }
}

#if (DEBUG)
struct HubList_Previews: PreviewProvider {
    static var previews: some View {
        HubListPreviewWrapper()
    }
}

struct HubListPreviewWrapper: View {
    @State var hubs = create_preview_hubs()
    var body: some View {
        HubList(hubs: $hubs)
    }
}
#endif
