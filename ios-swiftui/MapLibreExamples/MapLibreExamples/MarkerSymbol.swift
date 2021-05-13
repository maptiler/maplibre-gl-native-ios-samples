import Mapbox
import SwiftUI

struct MarkerSymbol: View {
    var body: some View {
        MarkerSymbolMap()
            .navigationTitle("Marker Symbol")
    }
}

struct MarkerSymbolMap: UIViewRepresentable {
    
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
    
    func createMarkerSymbol(_ mapView: MGLMapView, _ style: MGLStyle) {
        // Create point to represent where the symbol should be placed
        let point = MGLPointAnnotation()
        point.coordinate = mapView.centerCoordinate
         
        // Create a data source to hold the point data
        let shapeSource = MGLShapeSource(identifier: "marker-source", shape: point, options: nil)
         
        // Create a style layer for the symbol
        let shapeLayer = MGLSymbolStyleLayer(identifier: "marker-style", source: shapeSource)
         
        // Add the image to the style's sprite
        if let image = UIImage(named: "house-icon") {
            style.setImage(image, forName: "home-symbol")
        }
         
        // Tell the layer to use the image in the sprite
        shapeLayer.iconImageName = NSExpression(forConstantValue: "home-symbol")
         
        // Add the source and style layer to the map
        style.addSource(shapeSource)
        style.addLayer(shapeLayer)
    }
    
   
    func makeCoordinator() -> MarkerSymbolMap.Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, MGLMapViewDelegate {
        var control: MarkerSymbolMap
        
        init(_ control: MarkerSymbolMap) {
            self.control = control
        }
        
        func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
            self.control.createMarkerSymbol(mapView, style)
        }
    }
}

struct MarkerSymbolMap_Previews: PreviewProvider {
    static var previews: some View {
        MarkerSymbolMap()
    }
}
