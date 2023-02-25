//
//  RestaurantMapView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/17/23.
//

import SwiftUI
import MapKit


struct RestaurantMapView: View {
    @State private var restaurantData: RestaurantData?
    @State var mapLocations: [MapLocation]!
    @State var mapPins: [MKPlacemark]!
    @State private var showingTransition = true
    
    var body: some View {
        VStack {
            Text("Vegan Restaurants Nearby:")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 20)
    
            MapView()
            
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showingTransition = false
            }
        }
        .sheet(isPresented: $showingTransition) {
                   TransitionView()
               }
        
    }
    
    struct MapView: UIViewRepresentable {
        @State var restaurantData: RestaurantData?
        @State private var group = DispatchGroup()
        
        var locationManager = CLLocationManager()
        func setupManager() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        }
        
        func makeUIView(context: Context) -> MKMapView {
            setupManager()
            let mapView = MKMapView(frame: UIScreen.main.bounds)
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
            loadData()
            return mapView
        }
        
        func updateUIView(_ uiView: MKMapView, context: Context) {
            group.notify(queue: .main) {
                uiView.addAnnotations(createMapLocations())
                
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
            
            let request = NSMutableURLRequest(url: NSURL(string: "https://api.yelp.com/v3/businesses/search?term=vegan&open_now=true&location=Seattle&latitude=\(latitude ?? 0.0)&longitude=\(longitude ?? 0.0)&sort_by=distance&limit=20")! as URL,
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
    }
    
    struct RestaurantMapView_Previews: PreviewProvider {
        static var previews: some View {
            RestaurantMapView()
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
}
