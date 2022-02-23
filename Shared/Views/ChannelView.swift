//
//  ChannelView.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-20.
//

import SwiftUI

struct ChannelView: View {
    @Binding var channel: Channel
    @State var new_message: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Name: \(channel.name)")
                Spacer()
            }
            HStack {
                Text("Description: \(channel.description)")
                Spacer()
            }
            ScrollViewReader { proxy in
                MessageList(messages: $channel.messages)
//                    .onAppear {
//                    proxy.scrollTo(channel.messages[channel.messages.endIndex - 1].id)
//                }
                TextField("", text: $new_message, prompt: Text("New message...")).onSubmit {
                    let message = Message.init(id: UUID.init().uuidString, hub_id: channel.hub_id, channel_id: channel.id, sender: WICRSClient.user_id, created: Date.now.ISO8601Format(), content: new_message)
                    channel.messages.append(message)
                    proxy.scrollTo(message.id)
                    new_message = ""
                }
            }
        }.padding()
    }
}

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