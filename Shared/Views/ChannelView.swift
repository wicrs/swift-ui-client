//
//  ChannelView.swift
//  WICRS Client
//
//  Created by Willem on 2022-01-20.
//

import SwiftUI

struct ChannelView: View {
    @Binding var channel: Channel
    @State var new_message: String = ""
    
    var body: some View {
        VStack {
//            HStack {
//                Text("Description: \(channel.description)")
//                Spacer()
//            }
            MessageList(messages: $channel.messages)
            TextField("", text: $new_message, prompt: Text("New message...")).onSubmit {
                let _ = try! WICRSClient.http_client.send_message(hub_id: channel.hub_id, channel_id: channel.id, content: new_message)
                new_message = ""
            }
        }.padding()
    }
}

#if (DEBUG)
struct ChannelView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelPreviewWrapper()
    }
}

struct ChannelPreviewWrapper: View {
    @State var channel = create_preview_channel()
    
    var body: some View {
        ChannelView(channel: $channel)
    }
}
#endif
