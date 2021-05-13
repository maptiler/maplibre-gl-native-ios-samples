import Mapbox
import SwiftUI

struct ApproximateLocation: View {
    var body: some View {
        ApproximateLocationMap()
            .navigationTitle("Approximate User's Location")
    }
}

struct ApproximateLocationMap: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MGLMapView {
        // read the key from property list
        let mapTilerKey = Helper.getMapTilerkey()
        Helper.validateKey(mapTilerKey)
        
        // Use your custom style url
        let styleURL = URL(string: "https://api.maptiler.com/maps/streets/style.json?key=\(mapTilerKey)")
        
        // create the mapview
        let mapView = MGLMapView(frame: .zero, styleURL: styleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 41.8864, longitude: -87.7135), zoomLevel: 13, animated: false)
        
        // use the coordinator to respond to the map loaded event
        mapView.delegate = context.coordinator
        
        return mapView
    }
    
    func updateUIView(_ uiView: MGLMapView, context: Context) { }
    
    func makeCoordinator() -> ApproximateLocationMap.Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, MGLMapViewDelegate {
        var control: ApproximateLocationMap
        
        init(_ control: ApproximateLocationMap) {
            self.control = control
        }
        
        func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
            //self.control.createApproximateLocation(mapView, style)
        }
    }
}

struct ApproximateLocationMap_Previews: PreviewProvider {
    static var previews: some View {
        ApproximateLocationMap()
    }
}
