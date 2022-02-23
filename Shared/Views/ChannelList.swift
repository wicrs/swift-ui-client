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
    
    var body: some View {
        NavigationView {
            List($channels.sorted { $0.name.wrappedValue.compare($1.name.wrappedValue, options: [.caseInsensitive, .numeric]) == ComparisonResult.orderedAscending }) { channel in
                NavigationLink {
                    ChannelView(channel: channel)
                } label: {
                    ChannelRow(channel: channel)
                }
            }
        }.navigationTitle("Channels")
    }
}
#else
struct ChannelList: View {
    @Binding var channels: [Channel]
    
    var body: some View {
        List($channels.sorted { $0.name.wrappedValue < $1.name.wrappedValue }) { channel in
            NavigationLink {
                ChannelView(channel: channel)
            } label: {
                ChannelRow(channel: channel)
            }
        }
    }
}
#endif

struct ChannelList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChannelListPreviewWrapper()
        }
    }
}

struct ChannelListPreviewWrapper: View {
    @State var channels = create_preview_hub().channels.values
    
    var body: some View {
        ChannelList(channels: $channels)
    }
}
