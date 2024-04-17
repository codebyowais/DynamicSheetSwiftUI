//  DynamicBottomSheetModifier.swift
//  Keka
//
//  Created by Mohammed Owais on 18/09/23.
//

import SwiftUI

struct DynamicSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: SheetContent
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> SheetContent) {
        _isPresented = isPresented
        self.sheetContent = content()
    }
    
    @State private var yPosition: CGFloat = .zero
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .animation(.none, value: isPresented)
            
            // Sheet
            ZStack {
                if isPresented {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            isPresented = false
                        }
                    
                    VStack {
                        Spacer(minLength: 10)
                        DynamicBottomSheetContainer {
                            sheetContent
                        }
                        .offset(y: yPosition)
                        .onTapGesture { } // intensionally added to avoid gesture conflict with scroll view
                        .gesture(
                            DragGesture()
                                .onChanged({ value in
                                    if value.translation.height > 0 {
                                        yPosition = value.translation.height
                                    }
                                })
                                .onEnded({ _ in
                                    if yPosition > 100 {
                                        isPresented = false
                                    }
                                    yPosition = .zero
                                })
                        )
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                    .zIndex(1)
                }
            }
            .animation(.easeOut, value: isPresented)
        }
    }
}

struct DynamicBottomSheetContainer<Content>: View where Content: View {
    let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
                .padding(.vertical, 20)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background()
        .roundedCorner(12, corners: .topLeft)
        .roundedCorner(12, corners: .topRight)
        .shadow(color: .gray, radius: 2)
    }
}

// View extension for ease of use
extension View {
    /// This'll present a self sizing bottom sheet
    /// - Parameters:
    ///   - isPresented: will present the sheet when this get's true
    ///   - content: View inside bottom sheet
    public func dynamicSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(DynamicSheetModifier(isPresented: isPresented, content: content))
    }
    
    /// This'll present a self sizing bottom sheet
    /// - Parameters:
    ///   - Item: will present the sheet when this get's some value assing to it
    ///   - content: View inside bottom sheet
    public func dynamicSheet<Item: Swift.Identifiable, Content: View>(
        item binding: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        modifier(
            DynamicSheetModifier(
                isPresented: binding.mappedToBool(),
                content: {
                    if let item = binding.wrappedValue {
                        content(item)
                    }
                }
            )
        )
    }
}
