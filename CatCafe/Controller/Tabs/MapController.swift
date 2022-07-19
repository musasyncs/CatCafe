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
    private var selectedAnnotation: MKAnnotation?
    private var menuViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - View
    private lazy var backButton = makeIconButton(
        imagename: ImageAsset.Icons_24px_Close.rawValue,
        imageColor: .white,
        imageWidth: 24, imageHeight: 24,
        backgroundColor: UIColor(white: 0.5, alpha: 0.7),
        cornerRadius: 40 / 2
    )
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let menuView = MenuView()
    private let cafeInfoAlert = CafeInfoAlert()
    
    private lazy var centerMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "location_arrow_flat").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCenterLocation), for: .touchUpInside)
        return button
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        setupMapView()
        setupMenuView()
        setupCenterMapButton()
        
        enableLocationServices()
        
        fetchCafes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerMapOnUserLocation()
    }
        
    // MARK: - API
    private func fetchCafes() {
        CafeService.fetchAllCafes { [weak self] cafes in
            guard let self = self else { return }
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
            self.menuView.cafes = self.cafes
        }
    }
    
    // MARK: - Action
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.isHidden = false
    }
        
    @objc func handleCenterLocation() {
        centerMapOnUserLocation()
    }
    
    @objc func dissmissAlert() {
        cafeInfoAlert.dissmissAlert()
    }
    
    @objc func makePhoneCall() {
        cafeInfoAlert.makePhoneCall()
    }
    
    @objc func gotoWebsite() {
        cafeInfoAlert.gotoWebsite()
    }
    
}

extension MapController {

    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        view.addSubview(mapView)
        mapView.anchor(
            top: view.topAnchor,
            left: view.leftAnchor,
            bottom: view.bottomAnchor,
            right: view.rightAnchor,
            paddingBottom: 75
        )
    }
    
    private func setupMenuView() {
        menuView.delegate = self
        menuView.mapController = self
        view.addSubview(menuView)
        menuView.anchor(left: view.leftAnchor, right: view.rightAnchor, height: height2)
        menuViewBottomConstraint = menuView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: (height2 - 108)
        )
        menuViewBottomConstraint?.isActive = true
    }
    
    private func setupCenterMapButton() {
        view.addSubview(centerMapButton)
        centerMapButton.anchor(bottom: menuView.topAnchor,
                               right: view.rightAnchor,
                               paddingBottom: 16, paddingRight: 16,
                               width: 50, height: 50)
    }
}

extension MapController {
    
    private func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func zoomToFocus(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2DMake(
                coordinate.latitude,
                coordinate.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        safeSetRegion(region)
    }
    
    private func zoomToFit(selectedAnnotation: MKAnnotation?) {
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
                    bottomRightCoordinate.longitude = fmax(
                        bottomRightCoordinate.longitude,
                        userAnno.coordinate.longitude
                    )
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, userAnno.coordinate.latitude)
                }
                
                if annotation.title == selectedAnnotation.title {
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(
                        bottomRightCoordinate.longitude,
                        annotation.coordinate.longitude
                    )
                    bottomRightCoordinate.latitude = fmin(
                        bottomRightCoordinate.latitude,
                        annotation.coordinate.latitude
                    )
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

// MARK: - MenuViewDelegate
extension MapController: MenuViewDelegate {
    
    func shouldHideCenterButton(_ shouldHide: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.centerMapButton.alpha = shouldHide ? 0 : 1
        }
    }
    func animateBottomConstraint(constant: CGFloat, goalState: ExpansionState) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .curveEaseOut) {
                self.menuViewBottomConstraint?.constant = constant
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.menuView.expansionState = goalState
            }
    }
    
    func selectedAnnotation(withCafe cafe: Cafe) {
        mapView.annotations.forEach { [weak self] annotation in
            guard let self = self else { return }
            if annotation.title == cafe.title {
                self.mapView.selectAnnotation(annotation, animated: true)
                self.zoomToFit(selectedAnnotation: annotation)
                self.selectedAnnotation = annotation
            }
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
extension MapController: CLLocationManagerDelegate {
    
    func enableLocationServices() {
        locationManager.delegate = self
        
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is CafeAnnotation else { return nil }
        let annotationIdentifier = "cafe"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.image = UIImage.asset(.catAnno)?.resize(to: .init(width: 24, height: 24))
        
        annotationView?.canShowCallout = true
        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.setImage(
            UIImage.asset(.info)?
                .resize(to: .init(width: 17, height: 17))?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.ccPrimary),
            for: .normal
        )
        annotationView?.rightCalloutAccessoryView = rightButton
        
        annotationView?.doGlowAnimation(withColor: .ccGrey.withAlphaComponent(0.3), withEffect: .small)
        
        return annotationView
    }
    
    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        guard let annotation = view.annotation as? CafeAnnotation else { return }
        cafeInfoAlert.showAlert(with: annotation.title,
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
