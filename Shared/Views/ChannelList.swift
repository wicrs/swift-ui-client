//
//  ChannelList.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-20.
//

import SwiftUI

#if os(macOS)
struct ChannelList: View {
    @Binding var channels: Dictionary<UUIDString, Channel>.Values
    @Binding var hub_name: String
    
    var body: some View {
        NavigationView {
            List($channels.sorted { $0.name.wrappedValue.compare($1.name.wrappedValue, options: [.caseInsensitive, .numeric]) == ComparisonResult.orderedAscending }) { channel in
                NavigationLink {
                    ChannelView(channel: channel).navigationTitle("\(hub_name) : \(channel.wrappedValue.name)")
                } label: {
                    ChannelRow(channel: channel)
                }
            }
        }
    }
}
#else
struct ChannelList: View {
    @Binding var channels: Dictionary<UUIDString, Channel>.Values
    @Binding var hub_name: String
    
    var body: some View {
        List($channels.sorted { $0.name.wrappedValue.compare($1.name.wrappedValue, options: [.caseInsensitive, .numeric]) == ComparisonResult.orderedAscending }) { channel in
            NavigationLink {
                ChannelView(channel: channel).navigationTitle("\(hub_name) : \(channel.wrappedValue.name)")
            } label: {
                ChannelRow(channel: channel)
            }
        }
    }
}
#endif

#if (DEBUG)
struct ChannelList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChannelListPreviewWrapper()
        }
    }
}

struct ChannelListPreviewWrapper: View {
    @State var channels = create_preview_hub().channels.values
    @State var name = "Test"
    
    var body: some View {
        ChannelList(channels: $channels, hub_name: $name)
    }
}
#endif
