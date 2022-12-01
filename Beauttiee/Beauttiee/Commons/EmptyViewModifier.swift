//
//  EmptyViewModifier.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 22/11/22.
//

import Foundation
import SwiftUI

struct EmptyViewModifier<EmptyViewContent>: ViewModifier where EmptyViewContent: View {
  var isEmpty: Bool
  let emptyViewContent: () -> EmptyViewContent
  
  func body(content: Content) -> some View {
    if isEmpty {
        emptyViewContent()
    }
    else {
      content
    }
  }
}
