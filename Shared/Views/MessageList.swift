//
//  MessageList.swift
//  WICRS Client
//
//  Created by Willem on 2022-01-24.
//

import SwiftUI

struct MessageList: View {
    @Binding var messages: [Message]
    
    var last_message: UUIDString? {
        get {
            messages.sorted { $0.created.compare($1.created, options: [.caseInsensitive, .numeric]) == ComparisonResult.orderedAscending }.last?.id
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { proxy in
                LazyVStack {
                    ForEach(Array(messages.sorted { $0.created.compare($1.created, options: [.caseInsensitive, .numeric]) == ComparisonResult.orderedAscending }.enumerated()), id: \.offset) { index, message in
                        MessageRow(id: index, message: message).id(message.id)
                    }
                }.onChange(of: messages) { _ in
                    proxy.scrollTo(last_message)
                }.onAppear {
                    proxy.scrollTo(last_message)
                }
            }
        }
    }
}



func message_date_compare(a: Message, b: Message) throws -> Bool {
    let date_a = try Date.init(a.created, strategy: .iso8601)
    let date_b = try Date.init(b.created, strategy: .iso8601)
    return date_a.compare(date_b) == .orderedAscending
}

#if (DEBUG)
struct MessageListPreviewWrapper: View {
    @State var messages = create_preview_channel().messages
    
    var body: some View {
        MessageList(messages: $messages)
    }
}

struct MessageList_Previews: PreviewProvider {
    static var previews: some View {
        MessageListPreviewWrapper()
    }
}
#endif


