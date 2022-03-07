//
//  HubRow.swift
//  WICRS Client
//
//  Created by Willem Leitso on 2022-01-20.
//

import SwiftUI

struct HubRow: View {
    @Binding var hub: Hub
    
    var body: some View {
        HStack {
            Text(hub.name)
        }
    }
}

#if (DEBUG)
struct HubRow_Previews: PreviewProvider {
    static var previews: some View {
        HubRowPreviewWrapper()
    }
}

struct HubRowPreviewWrapper: View {
    @State var hub = create_preview_hub()
    var body: some View {
        HubRow(hub: $hub)
    }
}
#endif
