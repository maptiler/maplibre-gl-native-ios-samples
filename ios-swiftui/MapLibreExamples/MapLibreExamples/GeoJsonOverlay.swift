import Mapbox
import SwiftUI

struct GeoJsonOverlay: View {
    var body: some View {
        GeoJsonOverlayMap()
            .navigationTitle("GeoJson Overlay")
    }
}

struct GeoJsonOverlayMap: UIViewRepresentable {
    
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
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 45.5076, longitude: -122.6736), zoomLevel: 11, animated: false)
        
        // use the coordinator to respond to the map loaded event
        mapView.delegate = context.coordinator
        
        return mapView
    }
    
    func updateUIView(_ uiView: MGLMapView, context: Context) { }
    
    func loadGeoJson(_ mapView: MGLMapView) {
        // Load and parse geoJson on background, concurrent thread
        DispatchQueue.global().async {
            // Get the path for example.geojson in the app’s bundle.
            guard let jsonUrl = Bundle.main.url(forResource: "example", withExtension: "geojson") else {
                preconditionFailure("Failed to load local GeoJSON file")
            }
     
            guard let jsonData = try? Data(contentsOf: jsonUrl) else {
                preconditionFailure("Failed to parse GeoJSON file")
            }
     
            // update the map on UI thread
            DispatchQueue.main.async {
                self.drawPolyline(mapView, geoJson: jsonData)
            }
        }
    }
    
    func drawPolyline(_ mapView: MGLMapView, geoJson: Data) {
        // Add our GeoJSON data to the map as an MGLGeoJSONSource.
        // We can then reference this data from an MGLStyleLayer.

        // MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = mapView.style else { return }
 
        guard let shapeFromGeoJSON = try? MGLShape(data: geoJson,
            encoding: String.Encoding.utf8.rawValue) else {
            fatalError("Could not generate MGLShape")
        }
     
        // create source and add it to the style
        let source = self.createSource(style, fromShape: shapeFromGeoJSON)
     
        // prepare layer parameters
        // Set the line join and cap to a rounded end.
        let lineJoinCap = NSExpression(forConstantValue: "round")
        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18.
        // The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
        let lineWidth = NSExpression(
            format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
            [14: 2, 18: 20])
        
        // create layers
        let layer = createLayer(source, withLineJoinCap: lineJoinCap, withLineWidth: lineWidth)
        let casingLayer = createCasingLayer(source, withLineJoinCap: lineJoinCap)
        let dashedLayer = createDashLayer(source, withLineJoinCap: lineJoinCap, withLineWidth: lineWidth)
     
        // add layers to the style
        self.addLayers(style, layer, withCasing: casingLayer, withDashPattern: dashedLayer)
    }
    
    func createSource(_ style: MGLStyle, fromShape shape: MGLShape) -> MGLSource {
        let source = MGLShapeSource(identifier: "polyline", shape: shape, options: nil)
        style.addSource(source)
        return source
    }
    
    func addLayers(_ style: MGLStyle, _ layer: MGLStyleLayer, withCasing casingLayer: MGLStyleLayer, withDashPattern dashedLayer: MGLStyleLayer){
        style.addLayer(layer)
        style.addLayer(dashedLayer)
        style.insertLayer(casingLayer, below: layer)
    }
    
    func createLayer(_ source: MGLSource, withLineJoinCap lineJoinCap: NSExpression, withLineWidth lineWidth: NSExpression) -> MGLStyleLayer {
        // Create new layer for the line.
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = lineJoinCap
        layer.lineCap = lineJoinCap
        // Set the line color to a constant blue color.
        layer.lineColor = NSExpression(forConstantValue: UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1))
        layer.lineWidth = lineWidth
        
        return layer
    }
    
    func createCasingLayer(_ source: MGLSource, withLineJoinCap lineJoinCap: NSExpression) -> MGLStyleLayer {
        // We can also add a second layer that will draw a stroke around the original line.
        let casingLayer = MGLLineStyleLayer(identifier: "polyline-case", source: source)
        // Copy these attributes from the main line layer.
        casingLayer.lineJoin = lineJoinCap
        casingLayer.lineCap = lineJoinCap
        // Line gap width represents the space before the outline begins, so should match the main line’s line width exactly.
        casingLayer.lineGapWidth = casingLayer.lineWidth
        // Stroke color slightly darker than the line color.
        casingLayer.lineColor = NSExpression(forConstantValue: UIColor(red: 41/255, green: 145/255, blue: 171/255, alpha: 1))
        // Use `NSExpression` to gradually increase the stroke width between zoom levels 14 and 18.
        casingLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 1, 18: 4])
        
        return casingLayer
    }
    
    func createDashLayer(_ source: MGLSource, withLineJoinCap lineJoinCap: NSExpression, withLineWidth lineWidth: NSExpression) -> MGLStyleLayer {
        let dashedLayer = MGLLineStyleLayer(identifier: "polyline-dash", source: source)
        dashedLayer.lineJoin = lineJoinCap
        dashedLayer.lineCap = lineJoinCap
        dashedLayer.lineColor = NSExpression(forConstantValue: UIColor.white)
        dashedLayer.lineOpacity = NSExpression(forConstantValue: 0.5)
        dashedLayer.lineWidth = lineWidth
        // Dash pattern in the format [dash, gap, dash, gap, ...]. You’ll want to adjust these values based on the line cap style.
        dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0, 1.5])
    
        return dashedLayer
    }
    
    func makeCoordinator() -> GeoJsonOverlayMap.Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, MGLMapViewDelegate {
        var control: GeoJsonOverlayMap
        
        init(_ control: GeoJsonOverlayMap) {
            self.control = control
        }
        
        func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
            self.control.loadGeoJson(mapView)
        }

        func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
            // write your custom code which will be executed
            // after map has been loaded
        }
    }
}

struct GeoJsonOverlay_Previews: PreviewProvider {
    static var previews: some View {
        GeoJsonOverlay()
    }
}
