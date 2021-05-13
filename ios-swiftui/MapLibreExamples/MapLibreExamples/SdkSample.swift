import Foundation
import SwiftUI

struct SdkSample: Identifiable {
    let title: String
    let controller: AnyView
    let id: UUID

    init(title: String, controller: AnyView) {
        self.id = UUID()
        self.title = title
        self.controller = controller
    }
}

let sdkSamples = [
    SdkSample(title: "Basic Map", controller: AnyView(BasicMap())),
    SdkSample(title: "Annotations", controller:  AnyView(Annotations())),
    SdkSample(title: "Raster Overlay", controller:  AnyView(RasterOverlay())),
    SdkSample(title: "Custom Map", controller:  AnyView(CustomMap())),
    SdkSample(title: "GeoJson Overlay", controller:  AnyView(GeoJsonOverlay())),
    SdkSample(title: "Marker Symbol", controller:  AnyView(MarkerSymbol())),
    SdkSample(title: "Approximate Location", controller:  AnyView(ApproximateLocation()))
]
