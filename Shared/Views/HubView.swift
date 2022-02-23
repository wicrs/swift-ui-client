//
//  HubDetail.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-20.
//

import SwiftUI

struct HubView: View {
    @State var hub: Hub
    
    var body: some View {
        HStack {
            ChannelList(channels: $hub.channels.values)
            ScrollView {
                VStack {
                    HStack {
                        Text("Name: \(hub.name)")
                        Spacer()
                    }
                    HStack {
                        Text("Description: \(hub.description)")
                        Spacer()
                    }
                }.padding()
            }
        }
        .navigationTitle(hub.name)
    }
}

struct HubView_Previews: PreviewProvider {
    static var previews: some View {
        HubView(hub: create_preview_hub())
    }
}
