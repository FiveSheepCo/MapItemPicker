import SwiftUI

struct ImageSheet: View {
    let image: MapItemImage
    let dismiss: () -> Void
    
    var html: NSAttributedString? {
        if let data = image.description?.data(using: .utf8) {
            if let string = try? NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
            ) {
                string.setAttributes(
                    [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)],
                    range: .init(location: 0, length: string.length)
                )
                return string
            }
        }
        return nil
    }
    
    var footer: some View {
        VStack(alignment: .leading) {
            if let html {
                if #available(iOS 15, *) {
                    Text(AttributedString(html))
                } else {
                    Text(html.string)
                }
            } else if let description = image.description {
                Text(description)
            }
            if #available(iOS 15, *) {
                (
                    Text("image.source.teaser", bundle: .module) +
                    Text(" ") +
                    Text(AttributedString(
                        image.source.nameLocalizationKey.moduleLocalized,
                        attributes: .init([.link: image.sourceUrl])
                    ))
                )
                .padding(.top)
            } else {
                HStack {
                    Text("image.source.teaser", bundle: .module)
                    Button(image.source.nameLocalizationKey.moduleLocalized) {
                        UIApplication.shared.open(image.sourceUrl)
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                AsyncPhotoZoomView(url: image.url.absoluteString)
                Divider()
                HStack {
                    footer
                    Spacer(minLength: 0)
                }
                .multilineTextAlignment(.leading)
                .padding([.horizontal, .top])
                .background(Color.systemBackground)
            }
            .navigationBarItems(
                leading: Button {
                    dismiss()
                } label: {
                    Text("done", bundle: .module)
                }
            )
            .navigationBarTitle(Text("image", bundle: .module), displayMode: .inline)
        }
    }
}
