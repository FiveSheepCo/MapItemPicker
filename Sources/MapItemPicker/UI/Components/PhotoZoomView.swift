import SwiftUI
import UIKit
import PDFKit

struct PhotoZoomView: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = PDFDocument()
        guard let page = PDFPage(image: image) else { return view }
        view.document?.insert(page, at: 0)
        view.autoScales = true
        view.displayMode = .singlePage
        return view
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) { }
}
