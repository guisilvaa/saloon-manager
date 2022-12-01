//
//  ViewExtension.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 22/11/22.
//

import Foundation
import SwiftUI

extension View {
  func emptyView<EmptyViewContent>(_ isEmpty: Bool,
                                   emptyViewContent: @escaping () -> EmptyViewContent) -> some View where EmptyViewContent: View {
    modifier(EmptyViewModifier(isEmpty: isEmpty, emptyViewContent: emptyViewContent))
  }
}
