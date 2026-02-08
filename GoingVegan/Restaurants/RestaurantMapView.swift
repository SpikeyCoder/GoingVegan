//
//  RestaurantMapView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/17/23.
//

import SwiftUI
import MapKit
import CoreLocation


struct RestaurantMapView: View {
    @State private var restaurantData: RestaurantData?
    @State var mapLocations: [MapLocation]!
    @State var mapPins: [MKPlacemark]!
    
    var body: some View {
        VStack {
            Text("Restaurants with Vegan Options:")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 20)
    
            MapView()
            
        }
        .onAppear{}
    }
    
  
    
    struct RestaurantMapView_Previews: PreviewProvider {
        static var previews: some View {
            RestaurantMapView()
        }
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct MapView: UIViewRepresentable {
    @State var restaurantData: RestaurantData?
    @State private var group = DispatchGroup()
    @StateObject var locationManager = LocationManager()
    @State var ifFirst = true
    
    var region: MKCoordinateRegion {
        guard let location = locationManager.location else {
            return MKCoordinateRegion.spaceNeedleRegion()
        }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 50, longitudinalMeters: 50)
        return region
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.region = region
        mapView.delegate = context.coordinator
        loadData()
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        group.notify(queue: .main) {
            uiView.addAnnotations(createMapLocations())
            if ifFirst {
                let coords = CLLocationCoordinate2D(latitude: self.locationManager.location?.coordinate.latitude ?? 0.0, longitude: self.locationManager.location?.coordinate.longitude ?? 0.0)

                // set span (radius of points)
                let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)

                // set region
                let region = MKCoordinateRegion(center: coords, span: span)

                // set the view
                uiView.setRegion(region, animated: true)
            }
            ifFirst = false
            
        }
    }

    func createMapLocations() -> [MKPointAnnotation] {
        if let businesses = self.restaurantData?.businesses as? [Restaurant] {
            var i = 0
            let totalRestaurants = businesses.count
            var pins = [MKPointAnnotation]()
            while (i < totalRestaurants){
                pins.append(makeAnnotation(business: businesses[i]))
                i += 1
            }
            return pins
        }
        return [MKPointAnnotation]()
    }
    
    private func makeAnnotation(business:Restaurant) -> MKPointAnnotation {
                    
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(business.coordinates["latitude"] ?? 0.0), longitude: Double(business.coordinates["longitude"] ?? 0.0))
        annotation.title = business.name
        return annotation
    }
    
    private func loadData() {
        let latitude = CLLocationManager().location?.coordinate.latitude
        let longitude = CLLocationManager().location?.coordinate.longitude
        
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer K8sE8-KQi-rfbrHzdSwfp7a4jfTk-znfH9r_45Q4fX4xNNBEmP8PkVayZp8y2XhTH5F-p64z3iEalzIPdVPVD0cspnL9cQtXfsP-zo8eYFPk86q1HBsZHPbG1RDHY3Yx"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.yelp.com/v3/businesses/search?categories=vegan&open_now=false&&latitude=\(latitude ?? 0.0)&longitude=\(longitude ?? 0.0)&sort_by=distance&limit=50")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                guard let data = data else {return}
                if (error != nil) {
                    print(error as Any)
                }
                
                if let decodedData = try? JSONDecoder().decode(RestaurantData.self, from: data) {
                    DispatchQueue.main.async {
                        self.restaurantData = decodedData
                        group.leave()
                    }
                }
            }.resume()
        }
    }
}

struct RestaurantData: Decodable {
    var businesses: Array<Restaurant>
}

struct Restaurant: Decodable, Hashable {
    var name: String
    var coordinates: Dictionary<String, Double>
    var url: String
}

final class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

final class MapCoordinator: NSObject, MKMapViewDelegate {
    // 1.
    var parent: MapView
    var restaurantData: RestaurantData?
    var group = DispatchGroup()

    init(_ parent: MapView) {
        self.parent = parent
        super.init()
        loadData { restaurantData in
            self.restaurantData = restaurantData
        }
    }
    
    deinit {
        print("deinit: MapCoordinator")
    }
   
    func mapView(_: MKMapView, didSelect: MKAnnotation)
    {
        let lat:Double = didSelect.coordinate.latitude
        let lng:Double = didSelect.coordinate.longitude
        var annotationBusiness:Restaurant
        //Store it into Dictionary
        let locationDict = ["latitude": lat, "longitude": lng]
        guard let businesses = self.restaurantData?.businesses else {return}
        if businesses.count != 0 {
            annotationBusiness = businesses.filter{ $0.coordinates == locationDict}.first!
            guard let url = URL(string: annotationBusiness.url) else {return}
            UIApplication.shared.open(url)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
      //  guard let capital = view.annotation as? Checkpoint, let placeName = capital.title else { return }
       // parent.annotationOnTap(placeName)
    }
    
    private func loadData(completion: @escaping ((RestaurantData) -> Void)) {
        let latitude = CLLocationManager().location?.coordinate.latitude
        let longitude = CLLocationManager().location?.coordinate.longitude
        
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer K8sE8-KQi-rfbrHzdSwfp7a4jfTk-znfH9r_45Q4fX4xNNBEmP8PkVayZp8y2XhTH5F-p64z3iEalzIPdVPVD0cspnL9cQtXfsP-zo8eYFPk86q1HBsZHPbG1RDHY3Yx"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.yelp.com/v3/businesses/search?categories=vegan&open_now=false&&latitude=\(latitude ?? 0.0)&longitude=\(longitude ?? 0.0)&sort_by=distance&limit=50")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                guard let data = data else {return}
                if (error != nil) {
                    print(error as Any)
                }
                
                if let decodedData = try? JSONDecoder().decode(RestaurantData.self, from: data) {
                    DispatchQueue.main.async {
                        self.restaurantData = decodedData
                        completion(decodedData)
                        self.group.leave()
                        
                    }
                }
            }.resume()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.location = location
        }
    }
}

extension MKCoordinateRegion {
    
    static func spaceNeedleRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.6205, longitude: -122.3493), latitudinalMeters: 5000, longitudinalMeters: 5000)
    }
    
    func getBinding() -> Binding<MKCoordinateRegion>? {
        return Binding<MKCoordinateRegion>(.constant(self))
    }
}
