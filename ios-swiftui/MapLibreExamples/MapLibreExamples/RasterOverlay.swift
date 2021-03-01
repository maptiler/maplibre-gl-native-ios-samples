import SwiftUI
import Mapbox

struct RasterOverlay: View {
    var body: some View {
        MapWithRasterOverlay()
            .navigationTitle("Raster Overlay")
    }
}

struct MapWithRasterOverlay: UIViewRepresentable {
  
    func makeUIView(context: Context) -> MGLMapView {
        let mapTilerKey = Helper.getMapTilerkey()
        Helper.validateKey(mapTilerKey)
        
        // Build the style url
        let styleURL = URL(string: "https://api.maptiler.com/maps/topo/style.json?key=\(mapTilerKey)")
        
        // create the mapview
        let mapView = MGLMapView(frame: .zero, styleURL: styleURL)
        mapView.setCenter(CLLocationCoordinate2D(latitude: 50.90013625, longitude: 4.64086758), zoomLevel: 17, animated: false)
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.tintColor = .darkGray
        
        // use the coordinator only if you need
        // to respond to the map events
        mapView.delegate = context.coordinator
        
        return mapView
    }
    
    func updateUIView(_ uiView: MGLMapView, context: Context) {}
    
    func makeCoordinator() -> MapWithRasterOverlay.Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, MGLMapViewDelegate {
        var control: MapWithRasterOverlay
        
        init(_ control: MapWithRasterOverlay) {
            self.control = control
        }

        func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
            
            // Set the coordinate bounds for the raster image.
            let coordinates = MGLCoordinateQuad(
                topLeft: CLLocationCoordinate2D(latitude: 50.900867668253724, longitude: 4.639663696289062),
                bottomLeft: CLLocationCoordinate2D(latitude: 50.89935199434383, longitude: 4.639663696289062),
                bottomRight: CLLocationCoordinate2D(latitude: 50.89935199434383, longitude: 4.642066955566406),
                topRight: CLLocationCoordinate2D(latitude: 50.900867668253724, longitude: 4.642066955566406))
            
            // Create an MGLImageSource, used to add georeferenced raster images to a map.
            if let radarImage = UIImage(named: "aerial_wgs84.png") {
                
                let source = MGLImageSource(identifier: "aerial-image", coordinateQuad: coordinates, image: radarImage)
                style.addSource(source)

                // Create a raster layer from the MGLImageSource.
                let radarLayer = MGLRasterStyleLayer(identifier: "aerial-image-layer", source: source)

                // Insert the raster layer below the map's symbol layers.
                for layer in style.layers.reversed() {
                    if !layer.isKind(of: MGLSymbolStyleLayer.self) {
                        style.insertLayer(radarLayer, above: layer)
                        break
                    }
                }
            }
        }
    }
}

struct RasterOverlay_Previews: PreviewProvider {
    static var previews: some View {
        RasterOverlay()
    }
}
