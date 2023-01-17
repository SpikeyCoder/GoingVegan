//
//  RestaurantMapView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/17/23.
//

import SwiftUI
import MapKit

struct RestaurantMapView: View {
    var body: some View {
        VStack {
            MapView()
            Text("Select a restaurant:")
        }
        
    }
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



struct RestaurantMapView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantMapView()
    }
}
