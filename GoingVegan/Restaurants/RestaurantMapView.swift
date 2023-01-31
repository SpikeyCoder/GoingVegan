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
    
    var body: some View {
        VStack {
            MapView()
            Text("Vegan Restaurants Nearby:")
                .font(.headline)
                .fontWeight(.semibold)
            
            if restaurantData != nil {
                ForEach(restaurantData!.businesses, id: \.self){ business in
                    Text(business.name)
                }
            }
        }.onAppear(perform: loadData)
        
    }
    
    struct MapView: UIViewRepresentable {
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
            return mapView
        }
        
        func updateUIView(_ uiView: MKMapView, context: Context) {
        }
    }
        
    private func loadData() {
        let latitude = CLLocationManager().location?.coordinate.latitude
        let longitude = CLLocationManager().location?.coordinate.longitude
        
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer K8sE8-KQi-rfbrHzdSwfp7a4jfTk-znfH9r_45Q4fX4xNNBEmP8PkVayZp8y2XhTH5F-p64z3iEalzIPdVPVD0cspnL9cQtXfsP-zo8eYFPk86q1HBsZHPbG1RDHY3Yx"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.yelp.com/v3/businesses/search?location=Seattle&latitude=\(latitude ?? 0.0)&longitude=\(longitude ?? 0.0)&sort_by=best_match&limit=20")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data else {return}
            if (error != nil) {
                print(error as Any)
            } else {}
           
            if let decodedData = try? JSONDecoder().decode(RestaurantData.self, from: data) {
                DispatchQueue.main.async {
                    self.restaurantData = decodedData
                }
            }
        }.resume()
    }
    
    struct RestaurantData: Decodable {
        var businesses: Array<Restaurant>
    }
    
    struct Restaurant: Decodable, Hashable {
        var name: String
    }
    
    struct RestaurantMapView_Previews: PreviewProvider {
        static var previews: some View {
            RestaurantMapView()
        }
    }
}
