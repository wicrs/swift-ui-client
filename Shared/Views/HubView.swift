//
//  HubDetail.swift
//  WICRS Client
//
//  Created by Willem on 2022-01-20.
//

import SwiftUI

struct HubView: View {
    @Binding var hub: Hub
    
    var body: some View {
        VStack {
//            HStack {
//                Text("Description: \(hub.description)")
//                Spacer()
//            }
#if os(macOS)
            NavigationView {
                ChannelList(channels: $hub.channels.values, hub_name: $hub.name)
            }
#else
            ChannelList(channels: $hub.channels.values, hub_name: $hub.name)
#endif
        }
        .navigationTitle(hub.name)
    }
}

#if (DEBUG)
struct HubViewPreviewWrapper: View {
    @State var hub = create_preview_hub()
    
    var body: some View {
        HubView(hub: $hub)
    }
}

struct HubView_Previews: PreviewProvider {
    static var previews: some View {
        HubViewPreviewWrapper()
    }
}
#endif
