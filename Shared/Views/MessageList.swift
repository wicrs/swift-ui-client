//
//  MessageList.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-24.
//

import SwiftUI

struct MessageList: View {
    @Binding var messages: [Message]
    
    var body: some View {
        List(messages.sorted { $0.created.compare($1.created, options: [.caseInsensitive, .numeric]) == ComparisonResult.orderedAscending }) { message in
            HStack {
                Text(message.content)
                Spacer()
            }
#if os(iOS)
            .listRowBackground((index  % 2 == 0) ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
#endif
        }
#if os(macOS)
        .listStyle(.inset(alternatesRowBackgrounds: true))
#else
        .listStyle(GroupedListStyle())
#endif
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


