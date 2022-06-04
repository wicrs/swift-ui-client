//
//  ContentView.swift
//  Shared
//
//  Created by Willem on 2022-01-09.
//

import SwiftUI

struct ContentView: View {
    @Binding var hubs: [UUIDString:Hub]
//    @State private var joinID = ""
    
    var body: some View {
        HubList(hubs: $hubs)
#if os(iOS)
            .navigationViewStyle(.stack)
//#else
//            .toolbar {
//                TextField("Join Hub", text: $joinID).onSubmit(onJoin)
//            }
#endif
    }
    
//    private func onJoin() {
//        if (try? WICRSClient.http_client.join_hub(hub_id: joinID)) != nil {
//            hubs[joinID] = try? HubLoader.shared.loadHubSubscribe(joinID)
//            var in_hubs = AppConfig.hubs
//            in_hubs.append(joinID)
//            AppConfig.hubs = in_hubs
//        }
//        joinID = ""
//    }
}

#if (DEBUG)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewPreviewWrapper()
    }
}

struct ContentViewPreviewWrapper: View {
    @State var hubs = create_preview_hubs()
    
    var body: some View {
        ContentView(hubs: $hubs)
    }
}
#endif
