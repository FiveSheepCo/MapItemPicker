import SwiftUI

extension NavigationView {
    
    static var backgroundVisibilityAdjustable: Bool {
        if #available(iOS 16.0, *) {
            return true
        }
        return false
    }
}

extension View {
    
    @ViewBuilder func navigationBarBackgroundVisible() -> some View {
        if #available(iOS 16.0, *) {
            self.toolbarBackground(.visible, for: .navigationBar)
        } else {
            self
        }
    }
    
    func compatibleFullScreen<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(FullScreenModifier(isPresented: isPresented, builder: content))
    }
    
    @ViewBuilder func textCaseUppercase() -> some View {
        if #available(iOS 14.0, *) {
            self.textCase(.uppercase)
        } else {
            self
        }
    }
    
    @ViewBuilder func overlayCompatible<T: View>(alignment: Alignment, overlay: () -> T) -> some View {
        if #available(iOS 15, *) {
            self.overlay(alignment: alignment, content: overlay)
        } else {
            self.overlay(overlay(), alignment: alignment)
        }
    }
}

private struct FullScreenModifier<V: View>: ViewModifier {
    let isPresented: Binding<Bool>
    let builder: () -> V

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content.fullScreenCover(isPresented: isPresented, content: builder)
        } else {
            content.sheet(isPresented: isPresented, content: builder)
        }
    }
}
