//
//  LocationService.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

import Foundation
import CoreLocation
import Observation

@Observable
final class LocationService: NSObject {
    private let manager = CLLocationManager()
    
    var ubicacionActual: CLLocation?
    var autorizado: Bool = false
    var rumbo: CLLocationDirection = 0
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5  // actualiza cada 5m
    }
    
    func solicitarPermisos() {
        manager.requestWhenInUseAuthorization()
    }
    
    func iniciarSeguimiento() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
    
    func detenerSeguimiento() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }
    
    /// Distancia en metros entre la ubicación actual y un punto destino.
    func distanciaA(latitud: Double, longitud: Double) -> Double? {
        guard let actual = ubicacionActual else { return nil }
        let destino = CLLocation(latitude: latitud, longitude: longitud)
        return actual.distance(from: destino)
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            self.ubicacionActual = loc
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.rumbo = newHeading.trueHeading
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            autorizado = true
            iniciarSeguimiento()
        default:
            autorizado = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}
