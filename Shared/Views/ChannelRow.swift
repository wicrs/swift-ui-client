//
//  ChannelRow.swift
//  WICRS Client
//
//  Created by Willem on 2022-01-20.
//

import SwiftUI

struct ChannelRow: View {
    @Binding var channel: Channel
    var body: some View {
        Text(channel.name).help(channel.description)
    }
}

#if (DEBUG)
struct ChannelRowPreviewWrapper: View {
    @State var channel = create_preview_channel()
    
    var body: some View {
        ChannelRow(channel: $channel)
    }
}
struct ChannelRow_Previews: PreviewProvider {
    static var previews: some View {
        ChannelRowPreviewWrapper(channel: create_preview_channel())
    }
}
#endif
