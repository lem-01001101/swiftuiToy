//
//  Extensions.swift
//  swiftStarter
//
//  Created by Magtibay , Leo Jacinto  Malaluan on 6/12/24.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
