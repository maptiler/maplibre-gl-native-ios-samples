import SwiftUI
import Mapbox

struct CustomMap: View {
    var body: some View {
        MapWithSlopes()
            .navigationTitle("Custom Map")
    }
}

struct MapWithSlopes: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MGLMapView {
        // read the key from property list
        let mapTilerKey = Helper.getMapTilerkey()
        Helper.validateKey(mapTilerKey)
        
        // Use your custom style url
        // replace the map identifier (f3c7b19d-7f5b-42a2-8b98-90ed51ca373a) with your own identifier
        // see https://docs.maptiler.com/maplibre-gl-native-ios/ios-swiftui-custom-map/#publish-the-map
        let styleURL = URL(string: "https://api.maptiler.com/maps/f3c7b19d-7f5b-42a2-8b98-90ed51ca373a/style.json?key=\(mapTilerKey)")
        
        // create the mapview
        let mapView = MGLMapView(frame: .zero, styleURL: styleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
        
        let bounds = MGLCoordinateBounds(
                sw: CLLocationCoordinate2D(latitude: 46.91076825, longitude: 10.91279724),
                ne: CLLocationCoordinate2D(latitude: 46.98484291, longitude: 11.02306368))
        mapView.setVisibleCoordinateBounds(bounds, animated: false)
        mapView.setZoomLevel(12, animated: true)
        
        // use the coordinator only if you need
        // to respond to the map events
        mapView.delegate = context.coordinator
        
        return mapView
    }
    
    func updateUIView(_ uiView: MGLMapView, context: Context) {}
    
    func makeCoordinator() -> MapWithSlopes.Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, MGLMapViewDelegate {
        var control: MapWithSlopes
        
        init(_ control: MapWithSlopes) {
            self.control = control
        }

        func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
            // write your custom code which will be executed
            // after map has been loaded
        }
    }
    
}

struct CustomizedStyle_Previews: PreviewProvider {
    static var previews: some View {
        CustomMap()
    }
}
