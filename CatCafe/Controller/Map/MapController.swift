//
//  MapController.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/1.
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController {
    
    private var cafes = [Cafe]()
    var route: MKRoute?
    var selectedAnnotation: MKAnnotation?
    var inputViewBottomConstraint: NSLayoutConstraint?

    // MARK: - Views
    lazy var backButton = makeIconButton(imagename: "Icons_24px_Close",
                                         imageColor: .white,
                                         imageWidth: 24, imageHeight: 24,
                                         backgroundColor: UIColor(white: 0.5, alpha: 0.7),
                                         cornerRadius: 40 / 2)
    
    var mapView = MKMapView()
    var locationManager = CLLocationManager()
    var searchInputView = SearchInputView()
    let customAlert = CustomAlert()
    
    lazy var centerMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "location-arrow-flat").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCenterLocation), for: .touchUpInside)
        return button
    }()
    
    lazy var removeOverlaysButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_1x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(handleRemoveOverlays), for: .touchUpInside)
        button.alpha = 0
        return button
    }()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        configureViewComponents()
        enableLocationServices()
        
        fetchCafes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerMapOnUserLocation()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - API
    func fetchCafes() {
        CafeService.fetchAllCafes { cafes in
            self.cafes = cafes
            
            cafes.forEach { cafe in
                let annotation = CafeAnnotation(
                    title: cafe.title,
                    address: cafe.address,
                    coordinate: cafe.getCLLocationCoordinate2D(),
                    phoneNumber: cafe.phoneNumber,
                    website: cafe.website
                )
                self.mapView.addAnnotation(annotation)
            }
            self.searchInputView.cafes = self.cafes
        }
    }
    
    // MARK: - Selectors
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func handleRemoveOverlays() {
        UIView.animate(withDuration: 0.5) {
            self.removeOverlaysButton.alpha = 0
            self.centerMapButton.alpha = 1
        }

        centerMapOnUserLocation()
        
        guard let selectedAnno = self.selectedAnnotation else { return }
        mapView.deselectAnnotation(selectedAnno, animated: true)
    }
    
    @objc func handleCenterLocation() {
        centerMapOnUserLocation()
    }
    
    @objc func dissmissAlert() {
        customAlert.dissmissAlert()
    }
    
    @objc func makePhoneCall() {
        customAlert.makePhoneCall()
    }
    
    @objc func gotoWebsite() {
        customAlert.gotoWebsite()
    }
    
    // MARK: - Helper Functions
    func configureViewComponents() {
        view.backgroundColor = .white
        
        configureMapView()
        searchInputView.delegate = self
        searchInputView.mapController = self
        
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.layer.cornerRadius = 40 / 2
        backButton.clipsToBounds = true
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left: view.leftAnchor,
                          paddingTop: 4, paddingLeft: 24)
        backButton.setDimensions(height: 40, width: 40)
        
        view.addSubview(searchInputView)
        searchInputView.anchor(left: view.leftAnchor, right: view.rightAnchor, height: height2)
        inputViewBottomConstraint = searchInputView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: (height2 - 88)
        )
        inputViewBottomConstraint?.isActive = true
        
        view.addSubview(centerMapButton)
        centerMapButton.anchor(bottom: searchInputView.topAnchor,
                               right: view.rightAnchor,
                               paddingBottom: 16, paddingRight: 16,
                               width: 50, height: 50)
        
        view.addSubview(removeOverlaysButton)
        let dimension: CGFloat = 50
        removeOverlaysButton.anchor(left: view.leftAnchor,
                                    bottom: searchInputView.topAnchor,
                                    paddingLeft: 16, paddingBottom: 16,
                                    width: dimension, height: dimension)
        removeOverlaysButton.layer.cornerRadius = dimension / 2
    }
    
    func configureMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        view.addSubview(mapView)
        mapView.fillSuperView()
    }
}

// MARK: - MapKit Helper Functions
extension MapController {
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func zoomToFocus(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2DMake(
                coordinate.latitude,
                coordinate.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        safeSetRegion(region)
    }
    
    func zoomToFit(selectedAnnotation: MKAnnotation?) {
        if mapView.annotations.count == 0 {
            return
        }
        
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        if let selectedAnnotation = selectedAnnotation {
            for annotation in mapView.annotations {
                if let userAnno = annotation as? MKUserLocation {
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, userAnno.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, userAnno.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, userAnno.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, userAnno.coordinate.latitude)
                }
                
                if annotation.title == selectedAnnotation.title {
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
                }
            }
            
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2DMake(
                    topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.65,
                    topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.65
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: abs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 3.0,
                    longitudeDelta: abs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 3.0
                )
            )
            
            safeSetRegion(region)
        }
    }
    
    private func safeSetRegion(_ region: MKCoordinateRegion) {
        let myRegion = self.mapView.regionThatFits(region)
        if !(myRegion.span.latitudeDelta.isNaN || myRegion.span.longitudeDelta.isNaN) {

            // check for maximum span values (otherwise the setRegion(myRegion) call will crash)
            let deltaLat = min(180.0, myRegion.span.latitudeDelta)
            let deltaLong = min(360.0, myRegion.span.longitudeDelta)

            // now build a nice and easy span ...
            let coordinatesRegionWithSpan =  MKCoordinateSpan(
                         latitudeDelta: deltaLat,
                         longitudeDelta: deltaLong)

            // ... to use for an adjusted region
            let adjustedCoordinateRegion = MKCoordinateRegion(
                center: region.center,
                span: coordinatesRegionWithSpan)

            // and now it's safe to call
            self.mapView.setRegion(adjustedCoordinateRegion, animated: true)
        }
    }
}

// MARK: - SearchCellDelegate
extension MapController: SearchCellDelegate {
    func focus(forCafe cafe: Cafe) {
        let coordinate = CLLocationCoordinate2D(latitude: cafe.lat, longitude: cafe.long)
        zoomToFocus(coordinate: coordinate)
    }
}

// MARK: - SearchInputViewDelegate
extension MapController: SearchInputViewDelegate {
    
    func shouldHideCenterButton(_ shouldHide: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.centerMapButton.alpha = shouldHide ? 0 : 1
        }
    }
    func animateBottomConstraint(constant: CGFloat, goalState: ExpansionState) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.inputViewBottomConstraint?.constant = constant
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.searchInputView.expansionState = goalState
        }
    }
    
    func selectedAnnotation(withCafe cafe: Cafe) {
        mapView.annotations.forEach { (annotation) in
            if annotation.title == cafe.title {
                self.mapView.selectAnnotation(annotation, animated: true)
                self.zoomToFit(selectedAnnotation: annotation)
                self.selectedAnnotation = annotation
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.removeOverlaysButton.alpha = 1
                    self.centerMapButton.alpha = 0
                })
            }
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
extension MapController: CLLocationManagerDelegate {
    
    func enableLocationServices() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("Location auth status is NOT DETERMINED")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location auth status is RESTRICTED")
        case .denied:
            print("Location auth status is DENIED")
        case .authorizedAlways:
            print("Location auth status is AUTHORIZED ALWAYS")
        case .authorizedWhenInUse:
            print("Location auth status is AUTHORIZED WHEN IN USE")
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard locationManager.location != nil else {
            print("Error setting location..")
            return
        }
        centerMapOnUserLocation()
    }
}

// MARK: - MKMapViewDelegate
extension MapController: MKMapViewDelegate {
    
    // 自訂 annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is CafeAnnotation else { return nil }
        let annotationIdentifier = "cafe"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.canShowCallout = true
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        annotationView?.image = UIImage(named: "catAnno")?
            .resize(to: .init(width: 22, height: 22))
        
        return annotationView
    }
    
    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        guard let annotation = view.annotation as? CafeAnnotation else { return }
        customAlert.showAlert(with: annotation.title,
                              phoneNumber: annotation.phoneNumber,
                              website: annotation.website,
                              on: self)
    }
}

class CafeAnnotation: NSObject, MKAnnotation {
    let title: String?
    let address: String
    var coordinate: CLLocationCoordinate2D
    let phoneNumber: String
    let website: String
    
    init(title: String, address: String, coordinate: CLLocationCoordinate2D, phoneNumber: String, website: String) {
        self.title = title
        self.address = address
        self.coordinate = coordinate
        self.phoneNumber = phoneNumber
        self.website = website
    }
}

extension Cafe {
    func getCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
    }
}
