//
//  HubList.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-20.
//

import SwiftUI

struct HubList: View {
    @Binding var hubs: [Hub]
    
    var body: some View {
        NavigationView {
            List($hubs) { hub in
                NavigationLink {
                    ChannelList(channels: hub.channels.values)
                } label: {
                    HubRow(hub: hub)
                }
            }
        }.navigationTitle("Hubs")
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
