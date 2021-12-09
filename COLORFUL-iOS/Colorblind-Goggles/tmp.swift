//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import GPUImage
import MultiSelectSegmentedControl

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.view.backgroundColor = UIColor.black
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:5.0,width:200.0,height:50.0))
        self.setLabelTitle(title: self.name)
        self.view.addSubview(label)
//        self.view.fillMode = GPUImageFillModeType.preserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.isHidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let font:UIFont = UIFont(name: "Helvetica-Bold", size: 18.0)!
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadow.shadowColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
    }
}

class liveRestoreVC: UIViewController, MultiSelectSegmentedControlDelegate  {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index)) as IndexSet
        }
        
        activeFilters = segment.selectedSegmentTitles
        fitViewsOntoScreen()
    }
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageStillCamera?
    var stillImageSource:GPUImagePicture?
    var cameraPosition: AVCaptureDevice.Position = .back
    var percent = 100
    var lastLocation:CGPoint = CGPoint(x:0, y:0)
    var viewState:Int = 0
   
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    enum ViewState: Int {
        case ViewAll = 0, FilterLabelsHidden, BottomBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
        // Do any additional setup after loading the view, typically from a nib.
        
        segment.items = filterList.map{
            (filter) -> String in
            return filter.shortName
        }
        segment.selectedSegmentIndexes = NSIndexSet(index: 0) as IndexSet

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.detectPan))
        self.view.gestureRecognizers = [panRecognizer]


        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:#selector(self.incrementViewState))
            
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }

        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(infoButton)

        self.fitViewsOntoScreen()

        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            cameraMagic(position: cameraPosition)
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(position: self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in UIView.setAnimationsEnabled(true) }

      UIView.setAnimationsEnabled(false)

      super.viewWillTransition(to: size, with: coordinator)
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame: frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        self.filterList = setHiddenOnFilterStructs(activeFilters: self.activeFilters)
        let videoViews = getVisibleFilterStructs(_filterList: filterList)
        
        filterList[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        filterList[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
        filterList[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
        filterList[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
        filterList[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)

        if(frame.height >= frame.width){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        case  2:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width, height: frame.height)
        case  3:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/3, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/3 * 2, width: frame.width, height: frame.height)
        case 4:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
            videoViews[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
            videoViews[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            case  2:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/2, y: 0.0, width: frame.width, height: frame.height)
            case  3:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/3, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/3, y: 0.0, width: frame.width, height: frame.height)
            case 4:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
                videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[3].view.frame = CGRect(x: frame.width * 3/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[4].view.frame = CGRect(x: frame.width * 4/5, y: 0.0, width: frame.width, height: frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    @objc func incrementViewState(sender: AnyObject){

        self.viewState += 1
        
        switch (self.viewState){
        case ViewState.ViewAll.rawValue:
            bottomBar.isHidden = false
            infoButton.isHidden = false
            for filter in filterList{
                filter.label.isHidden = false
            }
        case ViewState.BottomBarHidden.rawValue:
            bottomBar.isHidden = true
            infoButton.isHidden = true
        case ViewState.FilterLabelsHidden.rawValue:
            for filter in filterList{
                filter.label.isHidden = true
            }
        default:
            self.viewState = -1
            incrementViewState(sender: self)
        }
        
        
  
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(hidden: true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(hidden: false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    

    func cameraMagic(position: AVCaptureDevice.Position){
        let orientation = UIApplication.shared.statusBarOrientation
        self.cameraMagic(position: position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevice.Position, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{

            let inputImage:UIImage = UIImage(imageLiteralResourceName: "test.jpg")
            stillImageSource = GPUImagePicture(image: inputImage)
            stillImageSource?.useNextFrameForImageCapture()


            for index in 0...(filterList.count - 1){
                stillImageSource?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.addTarget(self.filterList[index].view)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
            stillImageSource?.processImage()

        }
        
    }

    @IBAction func snapButtonTouchUpInside(_ sender: Any) {
        let view = containerView
        let viewImage:UIImage = view!.pb_takeSnapshot()
        saveImageToAlbum(image: viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRect(x: 0.0, y: 0.0, width: view!.bounds.width, height: view!.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRect(x: view!.bounds.width-40, y: view!.bounds.height, width: 40.0, height: 10.0 );
        tempView.genieInTransition(withDuration: 0.7, destinationRect: endRect, destinationEdge: BCRectEdge.top, completion: {
            tempView.removeFromSuperview()
        })
    }
    
    @IBAction func flipButtonTouchUpInside(_ sender: Any) {
        toggleCameraPosition()
        videoCamera?.stopCapture()
        cameraMagic(position: cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevice.Position.back){
            cameraPosition = AVCaptureDevice.Position.front
        }else{
            cameraPosition = AVCaptureDevice.Position.back
        }
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.location(in: containerView).y
        if recognizer.view != nil {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(title: self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(title: self.filterList[index].name)
            }
        }
    }
    
    @objc func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.shared.statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import GPUImage
import MultiSelectSegmentedControl

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.view.backgroundColor = UIColor.black
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:5.0,width:200.0,height:50.0))
        self.setLabelTitle(title: self.name)
        self.view.addSubview(label)
//        self.view.fillMode = GPUImageFillModeType.preserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.isHidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let font:UIFont = UIFont(name: "Helvetica-Bold", size: 18.0)!
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadow.shadowColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
    }
}

class liveRestoreVC: UIViewController, MultiSelectSegmentedControlDelegate  {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index)) as IndexSet
        }
        
        activeFilters = segment.selectedSegmentTitles
        fitViewsOntoScreen()
    }
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageStillCamera?
    var stillImageSource:GPUImagePicture?
    var cameraPosition: AVCaptureDevice.Position = .back
    var percent = 100
    var lastLocation:CGPoint = CGPoint(x:0, y:0)
    var viewState:Int = 0
   
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    enum ViewState: Int {
        case ViewAll = 0, FilterLabelsHidden, BottomBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
        // Do any additional setup after loading the view, typically from a nib.
        
        segment.items = filterList.map{
            (filter) -> String in
            return filter.shortName
        }
        segment.selectedSegmentIndexes = NSIndexSet(index: 0) as IndexSet

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.detectPan))
        self.view.gestureRecognizers = [panRecognizer]


        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:#selector(self.incrementViewState))
            
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }

        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(infoButton)

        self.fitViewsOntoScreen()

        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            cameraMagic(position: cameraPosition)
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(position: self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in UIView.setAnimationsEnabled(true) }

      UIView.setAnimationsEnabled(false)

      super.viewWillTransition(to: size, with: coordinator)
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame: frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        self.filterList = setHiddenOnFilterStructs(activeFilters: self.activeFilters)
        let videoViews = getVisibleFilterStructs(_filterList: filterList)
        
        filterList[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        filterList[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
        filterList[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
        filterList[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
        filterList[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)

        if(frame.height >= frame.width){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        case  2:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width, height: frame.height)
        case  3:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/3, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/3 * 2, width: frame.width, height: frame.height)
        case 4:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
            videoViews[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
            videoViews[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            case  2:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/2, y: 0.0, width: frame.width, height: frame.height)
            case  3:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/3, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/3, y: 0.0, width: frame.width, height: frame.height)
            case 4:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
                videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[3].view.frame = CGRect(x: frame.width * 3/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[4].view.frame = CGRect(x: frame.width * 4/5, y: 0.0, width: frame.width, height: frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    @objc func incrementViewState(sender: AnyObject){

        self.viewState += 1
        
        switch (self.viewState){
        case ViewState.ViewAll.rawValue:
            bottomBar.isHidden = false
            infoButton.isHidden = false
            for filter in filterList{
                filter.label.isHidden = false
            }
        case ViewState.BottomBarHidden.rawValue:
            bottomBar.isHidden = true
            infoButton.isHidden = true
        case ViewState.FilterLabelsHidden.rawValue:
            for filter in filterList{
                filter.label.isHidden = true
            }
        default:
            self.viewState = -1
            incrementViewState(sender: self)
        }
        
        
  
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(hidden: true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(hidden: false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    

    func cameraMagic(position: AVCaptureDevice.Position){
        let orientation = UIApplication.shared.statusBarOrientation
        self.cameraMagic(position: position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevice.Position, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{

            let inputImage:UIImage = UIImage(imageLiteralResourceName: "test.jpg")
            stillImageSource = GPUImagePicture(image: inputImage)
            stillImageSource?.useNextFrameForImageCapture()


            for index in 0...(filterList.count - 1){
                stillImageSource?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.addTarget(self.filterList[index].view)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
            stillImageSource?.processImage()

        }
        
    }

    @IBAction func snapButtonTouchUpInside(_ sender: Any) {
        let view = containerView
        let viewImage:UIImage = view!.pb_takeSnapshot()
        saveImageToAlbum(image: viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRect(x: 0.0, y: 0.0, width: view!.bounds.width, height: view!.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRect(x: view!.bounds.width-40, y: view!.bounds.height, width: 40.0, height: 10.0 );
        tempView.genieInTransition(withDuration: 0.7, destinationRect: endRect, destinationEdge: BCRectEdge.top, completion: {
            tempView.removeFromSuperview()
        })
    }
    
    @IBAction func flipButtonTouchUpInside(_ sender: Any) {
        toggleCameraPosition()
        videoCamera?.stopCapture()
        cameraMagic(position: cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevice.Position.back){
            cameraPosition = AVCaptureDevice.Position.front
        }else{
            cameraPosition = AVCaptureDevice.Position.back
        }
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.location(in: containerView).y
        if recognizer.view != nil {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(title: self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(title: self.filterList[index].name)
            }
        }
    }
    
    @objc func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.shared.statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import GPUImage
import MultiSelectSegmentedControl

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.view.backgroundColor = UIColor.black
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:5.0,width:200.0,height:50.0))
        self.setLabelTitle(title: self.name)
        self.view.addSubview(label)
//        self.view.fillMode = GPUImageFillModeType.preserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.isHidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let font:UIFont = UIFont(name: "Helvetica-Bold", size: 18.0)!
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadow.shadowColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
    }
}

class liveRestoreVC: UIViewController, MultiSelectSegmentedControlDelegate  {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index)) as IndexSet
        }
        
        activeFilters = segment.selectedSegmentTitles
        fitViewsOntoScreen()
    }
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageStillCamera?
    var stillImageSource:GPUImagePicture?
    var cameraPosition: AVCaptureDevice.Position = .back
    var percent = 100
    var lastLocation:CGPoint = CGPoint(x:0, y:0)
    var viewState:Int = 0
   
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    enum ViewState: Int {
        case ViewAll = 0, FilterLabelsHidden, BottomBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
        // Do any additional setup after loading the view, typically from a nib.
        
        segment.items = filterList.map{
            (filter) -> String in
            return filter.shortName
        }
        segment.selectedSegmentIndexes = NSIndexSet(index: 0) as IndexSet

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.detectPan))
        self.view.gestureRecognizers = [panRecognizer]


        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:#selector(self.incrementViewState))
            
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }

        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(infoButton)

        self.fitViewsOntoScreen()

        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            cameraMagic(position: cameraPosition)
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(position: self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in UIView.setAnimationsEnabled(true) }

      UIView.setAnimationsEnabled(false)

      super.viewWillTransition(to: size, with: coordinator)
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame: frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        self.filterList = setHiddenOnFilterStructs(activeFilters: self.activeFilters)
        let videoViews = getVisibleFilterStructs(_filterList: filterList)
        
        filterList[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        filterList[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
        filterList[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
        filterList[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
        filterList[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)

        if(frame.height >= frame.width){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        case  2:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width, height: frame.height)
        case  3:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/3, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/3 * 2, width: frame.width, height: frame.height)
        case 4:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
            videoViews[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
            videoViews[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            case  2:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/2, y: 0.0, width: frame.width, height: frame.height)
            case  3:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/3, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/3, y: 0.0, width: frame.width, height: frame.height)
            case 4:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
                videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[3].view.frame = CGRect(x: frame.width * 3/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[4].view.frame = CGRect(x: frame.width * 4/5, y: 0.0, width: frame.width, height: frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    @objc func incrementViewState(sender: AnyObject){

        self.viewState += 1
        
        switch (self.viewState){
        case ViewState.ViewAll.rawValue:
            bottomBar.isHidden = false
            infoButton.isHidden = false
            for filter in filterList{
                filter.label.isHidden = false
            }
        case ViewState.BottomBarHidden.rawValue:
            bottomBar.isHidden = true
            infoButton.isHidden = true
        case ViewState.FilterLabelsHidden.rawValue:
            for filter in filterList{
                filter.label.isHidden = true
            }
        default:
            self.viewState = -1
            incrementViewState(sender: self)
        }
        
        
  
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(hidden: true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(hidden: false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    

    func cameraMagic(position: AVCaptureDevice.Position){
        let orientation = UIApplication.shared.statusBarOrientation
        self.cameraMagic(position: position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevice.Position, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{

            let inputImage:UIImage = UIImage(imageLiteralResourceName: "test.jpg")
            stillImageSource = GPUImagePicture(image: inputImage)
            stillImageSource?.useNextFrameForImageCapture()


            for index in 0...(filterList.count - 1){
                stillImageSource?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.addTarget(self.filterList[index].view)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
            stillImageSource?.processImage()

        }
        
    }

    @IBAction func snapButtonTouchUpInside(_ sender: Any) {
        let view = containerView
        let viewImage:UIImage = view!.pb_takeSnapshot()
        saveImageToAlbum(image: viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRect(x: 0.0, y: 0.0, width: view!.bounds.width, height: view!.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRect(x: view!.bounds.width-40, y: view!.bounds.height, width: 40.0, height: 10.0 );
        tempView.genieInTransition(withDuration: 0.7, destinationRect: endRect, destinationEdge: BCRectEdge.top, completion: {
            tempView.removeFromSuperview()
        })
    }
    
    @IBAction func flipButtonTouchUpInside(_ sender: Any) {
        toggleCameraPosition()
        videoCamera?.stopCapture()
        cameraMagic(position: cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevice.Position.back){
            cameraPosition = AVCaptureDevice.Position.front
        }else{
            cameraPosition = AVCaptureDevice.Position.back
        }
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.location(in: containerView).y
        if recognizer.view != nil {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(title: self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(title: self.filterList[index].name)
            }
        }
    }
    
    @objc func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.shared.statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import GPUImage
import MultiSelectSegmentedControl

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.view.backgroundColor = UIColor.black
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:5.0,width:200.0,height:50.0))
        self.setLabelTitle(title: self.name)
        self.view.addSubview(label)
//        self.view.fillMode = GPUImageFillModeType.preserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.isHidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let font:UIFont = UIFont(name: "Helvetica-Bold", size: 18.0)!
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadow.shadowColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
    }
}

class liveRestoreVC: UIViewController, MultiSelectSegmentedControlDelegate  {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index)) as IndexSet
        }
        
        activeFilters = segment.selectedSegmentTitles
        fitViewsOntoScreen()
    }
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageStillCamera?
    var stillImageSource:GPUImagePicture?
    var cameraPosition: AVCaptureDevice.Position = .back
    var percent = 100
    var lastLocation:CGPoint = CGPoint(x:0, y:0)
    var viewState:Int = 0
   
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    enum ViewState: Int {
        case ViewAll = 0, FilterLabelsHidden, BottomBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
        // Do any additional setup after loading the view, typically from a nib.
        
        segment.items = filterList.map{
            (filter) -> String in
            return filter.shortName
        }
        segment.selectedSegmentIndexes = NSIndexSet(index: 0) as IndexSet

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.detectPan))
        self.view.gestureRecognizers = [panRecognizer]


        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:#selector(self.incrementViewState))
            
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }

        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(infoButton)

        self.fitViewsOntoScreen()

        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            cameraMagic(position: cameraPosition)
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(position: self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in UIView.setAnimationsEnabled(true) }

      UIView.setAnimationsEnabled(false)

      super.viewWillTransition(to: size, with: coordinator)
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame: frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        self.filterList = setHiddenOnFilterStructs(activeFilters: self.activeFilters)
        let videoViews = getVisibleFilterStructs(_filterList: filterList)
        
        filterList[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        filterList[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
        filterList[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
        filterList[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
        filterList[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)

        if(frame.height >= frame.width){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        case  2:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width, height: frame.height)
        case  3:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/3, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/3 * 2, width: frame.width, height: frame.height)
        case 4:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
            videoViews[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
            videoViews[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            case  2:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/2, y: 0.0, width: frame.width, height: frame.height)
            case  3:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/3, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/3, y: 0.0, width: frame.width, height: frame.height)
            case 4:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
                videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[3].view.frame = CGRect(x: frame.width * 3/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[4].view.frame = CGRect(x: frame.width * 4/5, y: 0.0, width: frame.width, height: frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    @objc func incrementViewState(sender: AnyObject){

        self.viewState += 1
        
        switch (self.viewState){
        case ViewState.ViewAll.rawValue:
            bottomBar.isHidden = false
            infoButton.isHidden = false
            for filter in filterList{
                filter.label.isHidden = false
            }
        case ViewState.BottomBarHidden.rawValue:
            bottomBar.isHidden = true
            infoButton.isHidden = true
        case ViewState.FilterLabelsHidden.rawValue:
            for filter in filterList{
                filter.label.isHidden = true
            }
        default:
            self.viewState = -1
            incrementViewState(sender: self)
        }
        
        
  
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(hidden: true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(hidden: false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    

    func cameraMagic(position: AVCaptureDevice.Position){
        let orientation = UIApplication.shared.statusBarOrientation
        self.cameraMagic(position: position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevice.Position, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{

            let inputImage:UIImage = UIImage(imageLiteralResourceName: "test.jpg")
            stillImageSource = GPUImagePicture(image: inputImage)
            stillImageSource?.useNextFrameForImageCapture()


            for index in 0...(filterList.count - 1){
                stillImageSource?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.addTarget(self.filterList[index].view)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
            stillImageSource?.processImage()

        }
        
    }

    @IBAction func snapButtonTouchUpInside(_ sender: Any) {
        let view = containerView
        let viewImage:UIImage = view!.pb_takeSnapshot()
        saveImageToAlbum(image: viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRect(x: 0.0, y: 0.0, width: view!.bounds.width, height: view!.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRect(x: view!.bounds.width-40, y: view!.bounds.height, width: 40.0, height: 10.0 );
        tempView.genieInTransition(withDuration: 0.7, destinationRect: endRect, destinationEdge: BCRectEdge.top, completion: {
            tempView.removeFromSuperview()
        })
    }
    
    @IBAction func flipButtonTouchUpInside(_ sender: Any) {
        toggleCameraPosition()
        videoCamera?.stopCapture()
        cameraMagic(position: cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevice.Position.back){
            cameraPosition = AVCaptureDevice.Position.front
        }else{
            cameraPosition = AVCaptureDevice.Position.back
        }
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.location(in: containerView).y
        if recognizer.view != nil {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(title: self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(title: self.filterList[index].name)
            }
        }
    }
    
    @objc func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.shared.statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import GPUImage
import MultiSelectSegmentedControl

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.view.backgroundColor = UIColor.black
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:5.0,width:200.0,height:50.0))
        self.setLabelTitle(title: self.name)
        self.view.addSubview(label)
//        self.view.fillMode = GPUImageFillModeType.preserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.isHidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let font:UIFont = UIFont(name: "Helvetica-Bold", size: 18.0)!
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadow.shadowColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
    }
}

class liveRestoreVC: UIViewController, MultiSelectSegmentedControlDelegate  {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index)) as IndexSet
        }
        
        activeFilters = segment.selectedSegmentTitles
        fitViewsOntoScreen()
    }
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageStillCamera?
    var stillImageSource:GPUImagePicture?
    var cameraPosition: AVCaptureDevice.Position = .back
    var percent = 100
    var lastLocation:CGPoint = CGPoint(x:0, y:0)
    var viewState:Int = 0
   
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    enum ViewState: Int {
        case ViewAll = 0, FilterLabelsHidden, BottomBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
        // Do any additional setup after loading the view, typically from a nib.
        
        segment.items = filterList.map{
            (filter) -> String in
            return filter.shortName
        }
        segment.selectedSegmentIndexes = NSIndexSet(index: 0) as IndexSet

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.detectPan))
        self.view.gestureRecognizers = [panRecognizer]


        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:#selector(self.incrementViewState))
            
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }

        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(infoButton)

        self.fitViewsOntoScreen()

        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            cameraMagic(position: cameraPosition)
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(position: self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in UIView.setAnimationsEnabled(true) }

      UIView.setAnimationsEnabled(false)

      super.viewWillTransition(to: size, with: coordinator)
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame: frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        self.filterList = setHiddenOnFilterStructs(activeFilters: self.activeFilters)
        let videoViews = getVisibleFilterStructs(_filterList: filterList)
        
        filterList[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        filterList[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
        filterList[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
        filterList[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
        filterList[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)

        if(frame.height >= frame.width){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        case  2:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width, height: frame.height)
        case  3:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/3, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/3 * 2, width: frame.width, height: frame.height)
        case 4:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
            videoViews[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
            videoViews[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            case  2:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/2, y: 0.0, width: frame.width, height: frame.height)
            case  3:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/3, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/3, y: 0.0, width: frame.width, height: frame.height)
            case 4:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
                videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[3].view.frame = CGRect(x: frame.width * 3/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[4].view.frame = CGRect(x: frame.width * 4/5, y: 0.0, width: frame.width, height: frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    @objc func incrementViewState(sender: AnyObject){

        self.viewState += 1
        
        switch (self.viewState){
        case ViewState.ViewAll.rawValue:
            bottomBar.isHidden = false
            infoButton.isHidden = false
            for filter in filterList{
                filter.label.isHidden = false
            }
        case ViewState.BottomBarHidden.rawValue:
            bottomBar.isHidden = true
            infoButton.isHidden = true
        case ViewState.FilterLabelsHidden.rawValue:
            for filter in filterList{
                filter.label.isHidden = true
            }
        default:
            self.viewState = -1
            incrementViewState(sender: self)
        }
        
        
  
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(hidden: true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(hidden: false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    

    func cameraMagic(position: AVCaptureDevice.Position){
        let orientation = UIApplication.shared.statusBarOrientation
        self.cameraMagic(position: position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevice.Position, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{

            let inputImage:UIImage = UIImage(imageLiteralResourceName: "test.jpg")
            stillImageSource = GPUImagePicture(image: inputImage)
            stillImageSource?.useNextFrameForImageCapture()


            for index in 0...(filterList.count - 1){
                stillImageSource?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.addTarget(self.filterList[index].view)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
            stillImageSource?.processImage()

        }
        
    }

    @IBAction func snapButtonTouchUpInside(_ sender: Any) {
        let view = containerView
        let viewImage:UIImage = view!.pb_takeSnapshot()
        saveImageToAlbum(image: viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRect(x: 0.0, y: 0.0, width: view!.bounds.width, height: view!.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRect(x: view!.bounds.width-40, y: view!.bounds.height, width: 40.0, height: 10.0 );
        tempView.genieInTransition(withDuration: 0.7, destinationRect: endRect, destinationEdge: BCRectEdge.top, completion: {
            tempView.removeFromSuperview()
        })
    }
    
    @IBAction func flipButtonTouchUpInside(_ sender: Any) {
        toggleCameraPosition()
        videoCamera?.stopCapture()
        cameraMagic(position: cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevice.Position.back){
            cameraPosition = AVCaptureDevice.Position.front
        }else{
            cameraPosition = AVCaptureDevice.Position.back
        }
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.location(in: containerView).y
        if recognizer.view != nil {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(title: self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(title: self.filterList[index].name)
            }
        }
    }
    
    @objc func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.shared.statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import GPUImage
import MultiSelectSegmentedControl

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.view.backgroundColor = UIColor.black
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:5.0,width:200.0,height:50.0))
        self.setLabelTitle(title: self.name)
        self.view.addSubview(label)
//        self.view.fillMode = GPUImageFillModeType.preserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.isHidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let font:UIFont = UIFont(name: "Helvetica-Bold", size: 18.0)!
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadow.shadowColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
    }
}

class liveRestoreVC: UIViewController, MultiSelectSegmentedControlDelegate  {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index)) as IndexSet
        }
        
        activeFilters = segment.selectedSegmentTitles
        fitViewsOntoScreen()
    }
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageStillCamera?
    var stillImageSource:GPUImagePicture?
    var cameraPosition: AVCaptureDevice.Position = .back
    var percent = 100
    var lastLocation:CGPoint = CGPoint(x:0, y:0)
    var viewState:Int = 0
   
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    enum ViewState: Int {
        case ViewAll = 0, FilterLabelsHidden, BottomBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
        // Do any additional setup after loading the view, typically from a nib.
        
        segment.items = filterList.map{
            (filter) -> String in
            return filter.shortName
        }
        segment.selectedSegmentIndexes = NSIndexSet(index: 0) as IndexSet

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.detectPan))
        self.view.gestureRecognizers = [panRecognizer]


        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:#selector(self.incrementViewState))
            
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }

        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(infoButton)

        self.fitViewsOntoScreen()

        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            cameraMagic(position: cameraPosition)
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(position: self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in UIView.setAnimationsEnabled(true) }

      UIView.setAnimationsEnabled(false)

      super.viewWillTransition(to: size, with: coordinator)
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame: frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        self.filterList = setHiddenOnFilterStructs(activeFilters: self.activeFilters)
        let videoViews = getVisibleFilterStructs(_filterList: filterList)
        
        filterList[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        filterList[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
        filterList[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
        filterList[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
        filterList[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)

        if(frame.height >= frame.width){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        case  2:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width, height: frame.height)
        case  3:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/3, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/3 * 2, width: frame.width, height: frame.height)
        case 4:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
            videoViews[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
            videoViews[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            case  2:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/2, y: 0.0, width: frame.width, height: frame.height)
            case  3:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/3, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/3, y: 0.0, width: frame.width, height: frame.height)
            case 4:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
                videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[3].view.frame = CGRect(x: frame.width * 3/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[4].view.frame = CGRect(x: frame.width * 4/5, y: 0.0, width: frame.width, height: frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    @objc func incrementViewState(sender: AnyObject){

        self.viewState += 1
        
        switch (self.viewState){
        case ViewState.ViewAll.rawValue:
            bottomBar.isHidden = false
            infoButton.isHidden = false
            for filter in filterList{
                filter.label.isHidden = false
            }
        case ViewState.BottomBarHidden.rawValue:
            bottomBar.isHidden = true
            infoButton.isHidden = true
        case ViewState.FilterLabelsHidden.rawValue:
            for filter in filterList{
                filter.label.isHidden = true
            }
        default:
            self.viewState = -1
            incrementViewState(sender: self)
        }
        
        
  
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(hidden: true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(hidden: false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    

    func cameraMagic(position: AVCaptureDevice.Position){
        let orientation = UIApplication.shared.statusBarOrientation
        self.cameraMagic(position: position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevice.Position, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{

            let inputImage:UIImage = UIImage(imageLiteralResourceName: "test.jpg")
            stillImageSource = GPUImagePicture(image: inputImage)
            stillImageSource?.useNextFrameForImageCapture()


            for index in 0...(filterList.count - 1){
                stillImageSource?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.addTarget(self.filterList[index].view)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
            stillImageSource?.processImage()

        }
        
    }

    @IBAction func snapButtonTouchUpInside(_ sender: Any) {
        let view = containerView
        let viewImage:UIImage = view!.pb_takeSnapshot()
        saveImageToAlbum(image: viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRect(x: 0.0, y: 0.0, width: view!.bounds.width, height: view!.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRect(x: view!.bounds.width-40, y: view!.bounds.height, width: 40.0, height: 10.0 );
        tempView.genieInTransition(withDuration: 0.7, destinationRect: endRect, destinationEdge: BCRectEdge.top, completion: {
            tempView.removeFromSuperview()
        })
    }
    
    @IBAction func flipButtonTouchUpInside(_ sender: Any) {
        toggleCameraPosition()
        videoCamera?.stopCapture()
        cameraMagic(position: cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevice.Position.back){
            cameraPosition = AVCaptureDevice.Position.front
        }else{
            cameraPosition = AVCaptureDevice.Position.back
        }
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.location(in: containerView).y
        if recognizer.view != nil {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(title: self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(title: self.filterList[index].name)
            }
        }
    }
    
    @objc func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.shared.statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import GPUImage
import MultiSelectSegmentedControl

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.view.backgroundColor = UIColor.black
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:5.0,width:200.0,height:50.0))
        self.setLabelTitle(title: self.name)
        self.view.addSubview(label)
//        self.view.fillMode = GPUImageFillModeType.preserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.isHidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let font:UIFont = UIFont(name: "Helvetica-Bold", size: 18.0)!
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadow.shadowColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
    }
}

class liveRestoreVC: UIViewController, MultiSelectSegmentedControlDelegate  {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index)) as IndexSet
        }
        
        activeFilters = segment.selectedSegmentTitles
        fitViewsOntoScreen()
    }
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageStillCamera?
    var stillImageSource:GPUImagePicture?
    var cameraPosition: AVCaptureDevice.Position = .back
    var percent = 100
    var lastLocation:CGPoint = CGPoint(x:0, y:0)
    var viewState:Int = 0
   
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    enum ViewState: Int {
        case ViewAll = 0, FilterLabelsHidden, BottomBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
        // Do any additional setup after loading the view, typically from a nib.
        
        segment.items = filterList.map{
            (filter) -> String in
            return filter.shortName
        }
        segment.selectedSegmentIndexes = NSIndexSet(index: 0) as IndexSet

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.detectPan))
        self.view.gestureRecognizers = [panRecognizer]


        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:#selector(self.incrementViewState))
            
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }

        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(infoButton)

        self.fitViewsOntoScreen()

        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            cameraMagic(position: cameraPosition)
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(position: self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in UIView.setAnimationsEnabled(true) }

      UIView.setAnimationsEnabled(false)

      super.viewWillTransition(to: size, with: coordinator)
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame: frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        self.filterList = setHiddenOnFilterStructs(activeFilters: self.activeFilters)
        let videoViews = getVisibleFilterStructs(_filterList: filterList)
        
        filterList[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        filterList[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
        filterList[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
        filterList[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
        filterList[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)

        if(frame.height >= frame.width){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        case  2:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width, height: frame.height)
        case  3:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/3, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/3 * 2, width: frame.width, height: frame.height)
        case 4:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
            videoViews[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
            videoViews[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            case  2:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/2, y: 0.0, width: frame.width, height: frame.height)
            case  3:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/3, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/3, y: 0.0, width: frame.width, height: frame.height)
            case 4:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
                videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[3].view.frame = CGRect(x: frame.width * 3/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[4].view.frame = CGRect(x: frame.width * 4/5, y: 0.0, width: frame.width, height: frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    @objc func incrementViewState(sender: AnyObject){

        self.viewState += 1
        
        switch (self.viewState){
        case ViewState.ViewAll.rawValue:
            bottomBar.isHidden = false
            infoButton.isHidden = false
            for filter in filterList{
                filter.label.isHidden = false
            }
        case ViewState.BottomBarHidden.rawValue:
            bottomBar.isHidden = true
            infoButton.isHidden = true
        case ViewState.FilterLabelsHidden.rawValue:
            for filter in filterList{
                filter.label.isHidden = true
            }
        default:
            self.viewState = -1
            incrementViewState(sender: self)
        }
        
        
  
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(hidden: true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(hidden: false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    

    func cameraMagic(position: AVCaptureDevice.Position){
        let orientation = UIApplication.shared.statusBarOrientation
        self.cameraMagic(position: position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevice.Position, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{

            let inputImage:UIImage = UIImage(imageLiteralResourceName: "test.jpg")
            stillImageSource = GPUImagePicture(image: inputImage)
            stillImageSource?.useNextFrameForImageCapture()


            for index in 0...(filterList.count - 1){
                stillImageSource?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.addTarget(self.filterList[index].view)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
            stillImageSource?.processImage()

        }
        
    }

    @IBAction func snapButtonTouchUpInside(_ sender: Any) {
        let view = containerView
        let viewImage:UIImage = view!.pb_takeSnapshot()
        saveImageToAlbum(image: viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRect(x: 0.0, y: 0.0, width: view!.bounds.width, height: view!.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRect(x: view!.bounds.width-40, y: view!.bounds.height, width: 40.0, height: 10.0 );
        tempView.genieInTransition(withDuration: 0.7, destinationRect: endRect, destinationEdge: BCRectEdge.top, completion: {
            tempView.removeFromSuperview()
        })
    }
    
    @IBAction func flipButtonTouchUpInside(_ sender: Any) {
        toggleCameraPosition()
        videoCamera?.stopCapture()
        cameraMagic(position: cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevice.Position.back){
            cameraPosition = AVCaptureDevice.Position.front
        }else{
            cameraPosition = AVCaptureDevice.Position.back
        }
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.location(in: containerView).y
        if recognizer.view != nil {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(title: self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(title: self.filterList[index].name)
            }
        }
    }
    
    @objc func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.shared.statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import GPUImage
import MultiSelectSegmentedControl

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.view.backgroundColor = UIColor.black
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:5.0,width:200.0,height:50.0))
        self.setLabelTitle(title: self.name)
        self.view.addSubview(label)
//        self.view.fillMode = GPUImageFillModeType.preserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.isHidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let font:UIFont = UIFont(name: "Helvetica-Bold", size: 18.0)!
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadow.shadowColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
    }
}

class liveRestoreVC: UIViewController, MultiSelectSegmentedControlDelegate  {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index)) as IndexSet
        }
        
        activeFilters = segment.selectedSegmentTitles
        fitViewsOntoScreen()
    }
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageStillCamera?
    var stillImageSource:GPUImagePicture?
    var cameraPosition: AVCaptureDevice.Position = .back
    var percent = 100
    var lastLocation:CGPoint = CGPoint(x:0, y:0)
    var viewState:Int = 0
   
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    enum ViewState: Int {
        case ViewAll = 0, FilterLabelsHidden, BottomBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
        // Do any additional setup after loading the view, typically from a nib.
        
        segment.items = filterList.map{
            (filter) -> String in
            return filter.shortName
        }
        segment.selectedSegmentIndexes = NSIndexSet(index: 0) as IndexSet

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.detectPan))
        self.view.gestureRecognizers = [panRecognizer]


        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:#selector(self.incrementViewState))
            
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }

        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(infoButton)

        self.fitViewsOntoScreen()

        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            cameraMagic(position: cameraPosition)
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(position: self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in UIView.setAnimationsEnabled(true) }

      UIView.setAnimationsEnabled(false)

      super.viewWillTransition(to: size, with: coordinator)
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame: frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        self.filterList = setHiddenOnFilterStructs(activeFilters: self.activeFilters)
        let videoViews = getVisibleFilterStructs(_filterList: filterList)
        
        filterList[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        filterList[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
        filterList[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
        filterList[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
        filterList[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)

        if(frame.height >= frame.width){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        case  2:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width, height: frame.height)
        case  3:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/3, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/3 * 2, width: frame.width, height: frame.height)
        case 4:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
            videoViews[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
            videoViews[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            case  2:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/2, y: 0.0, width: frame.width, height: frame.height)
            case  3:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/3, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/3, y: 0.0, width: frame.width, height: frame.height)
            case 4:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
                videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[3].view.frame = CGRect(x: frame.width * 3/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[4].view.frame = CGRect(x: frame.width * 4/5, y: 0.0, width: frame.width, height: frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    @objc func incrementViewState(sender: AnyObject){

        self.viewState += 1
        
        switch (self.viewState){
        case ViewState.ViewAll.rawValue:
            bottomBar.isHidden = false
            infoButton.isHidden = false
            for filter in filterList{
                filter.label.isHidden = false
            }
        case ViewState.BottomBarHidden.rawValue:
            bottomBar.isHidden = true
            infoButton.isHidden = true
        case ViewState.FilterLabelsHidden.rawValue:
            for filter in filterList{
                filter.label.isHidden = true
            }
        default:
            self.viewState = -1
            incrementViewState(sender: self)
        }
        
        
  
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(hidden: true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(hidden: false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    

    func cameraMagic(position: AVCaptureDevice.Position){
        let orientation = UIApplication.shared.statusBarOrientation
        self.cameraMagic(position: position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevice.Position, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{

            let inputImage:UIImage = UIImage(imageLiteralResourceName: "test.jpg")
            stillImageSource = GPUImagePicture(image: inputImage)
            stillImageSource?.useNextFrameForImageCapture()


            for index in 0...(filterList.count - 1){
                stillImageSource?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.addTarget(self.filterList[index].view)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
            stillImageSource?.processImage()

        }
        
    }

    @IBAction func snapButtonTouchUpInside(_ sender: Any) {
        let view = containerView
        let viewImage:UIImage = view!.pb_takeSnapshot()
        saveImageToAlbum(image: viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRect(x: 0.0, y: 0.0, width: view!.bounds.width, height: view!.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRect(x: view!.bounds.width-40, y: view!.bounds.height, width: 40.0, height: 10.0 );
        tempView.genieInTransition(withDuration: 0.7, destinationRect: endRect, destinationEdge: BCRectEdge.top, completion: {
            tempView.removeFromSuperview()
        })
    }
    
    @IBAction func flipButtonTouchUpInside(_ sender: Any) {
        toggleCameraPosition()
        videoCamera?.stopCapture()
        cameraMagic(position: cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevice.Position.back){
            cameraPosition = AVCaptureDevice.Position.front
        }else{
            cameraPosition = AVCaptureDevice.Position.back
        }
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.location(in: containerView).y
        if recognizer.view != nil {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(title: self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(title: self.filterList[index].name)
            }
        }
    }
    
    @objc func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.shared.statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import GPUImage
import MultiSelectSegmentedControl

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.view.backgroundColor = UIColor.black
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:5.0,width:200.0,height:50.0))
        self.setLabelTitle(title: self.name)
        self.view.addSubview(label)
//        self.view.fillMode = GPUImageFillModeType.preserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.isHidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let font:UIFont = UIFont(name: "Helvetica-Bold", size: 18.0)!
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadow.shadowColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
    }
}

class liveRestoreVC: UIViewController, MultiSelectSegmentedControlDelegate  {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index)) as IndexSet
        }
        
        activeFilters = segment.selectedSegmentTitles
        fitViewsOntoScreen()
    }
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageStillCamera?
    var stillImageSource:GPUImagePicture?
    var cameraPosition: AVCaptureDevice.Position = .back
    var percent = 100
    var lastLocation:CGPoint = CGPoint(x:0, y:0)
    var viewState:Int = 0
   
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    enum ViewState: Int {
        case ViewAll = 0, FilterLabelsHidden, BottomBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
        // Do any additional setup after loading the view, typically from a nib.
        
        segment.items = filterList.map{
            (filter) -> String in
            return filter.shortName
        }
        segment.selectedSegmentIndexes = NSIndexSet(index: 0) as IndexSet

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.detectPan))
        self.view.gestureRecognizers = [panRecognizer]


        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:#selector(self.incrementViewState))
            
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }

        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(infoButton)

        self.fitViewsOntoScreen()

        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            cameraMagic(position: cameraPosition)
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(position: self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in UIView.setAnimationsEnabled(true) }

      UIView.setAnimationsEnabled(false)

      super.viewWillTransition(to: size, with: coordinator)
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame: frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        self.filterList = setHiddenOnFilterStructs(activeFilters: self.activeFilters)
        let videoViews = getVisibleFilterStructs(_filterList: filterList)
        
        filterList[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        filterList[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
        filterList[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
        filterList[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
        filterList[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)

        if(frame.height >= frame.width){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        case  2:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width, height: frame.height)
        case  3:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/3, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/3 * 2, width: frame.width, height: frame.height)
        case 4:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
            videoViews[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
            videoViews[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            case  2:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/2, y: 0.0, width: frame.width, height: frame.height)
            case  3:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/3, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/3, y: 0.0, width: frame.width, height: frame.height)
            case 4:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
                videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[3].view.frame = CGRect(x: frame.width * 3/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[4].view.frame = CGRect(x: frame.width * 4/5, y: 0.0, width: frame.width, height: frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    @objc func incrementViewState(sender: AnyObject){

        self.viewState += 1
        
        switch (self.viewState){
        case ViewState.ViewAll.rawValue:
            bottomBar.isHidden = false
            infoButton.isHidden = false
            for filter in filterList{
                filter.label.isHidden = false
            }
        case ViewState.BottomBarHidden.rawValue:
            bottomBar.isHidden = true
            infoButton.isHidden = true
        case ViewState.FilterLabelsHidden.rawValue:
            for filter in filterList{
                filter.label.isHidden = true
            }
        default:
            self.viewState = -1
            incrementViewState(sender: self)
        }
        
        
  
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(hidden: true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(hidden: false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    

    func cameraMagic(position: AVCaptureDevice.Position){
        let orientation = UIApplication.shared.statusBarOrientation
        self.cameraMagic(position: position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevice.Position, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{

            let inputImage:UIImage = UIImage(imageLiteralResourceName: "test.jpg")
            stillImageSource = GPUImagePicture(image: inputImage)
            stillImageSource?.useNextFrameForImageCapture()


            for index in 0...(filterList.count - 1){
                stillImageSource?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.addTarget(self.filterList[index].view)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
            stillImageSource?.processImage()

        }
        
    }

    @IBAction func snapButtonTouchUpInside(_ sender: Any) {
        let view = containerView
        let viewImage:UIImage = view!.pb_takeSnapshot()
        saveImageToAlbum(image: viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRect(x: 0.0, y: 0.0, width: view!.bounds.width, height: view!.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRect(x: view!.bounds.width-40, y: view!.bounds.height, width: 40.0, height: 10.0 );
        tempView.genieInTransition(withDuration: 0.7, destinationRect: endRect, destinationEdge: BCRectEdge.top, completion: {
            tempView.removeFromSuperview()
        })
    }
    
    @IBAction func flipButtonTouchUpInside(_ sender: Any) {
        toggleCameraPosition()
        videoCamera?.stopCapture()
        cameraMagic(position: cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevice.Position.back){
            cameraPosition = AVCaptureDevice.Position.front
        }else{
            cameraPosition = AVCaptureDevice.Position.back
        }
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.location(in: containerView).y
        if recognizer.view != nil {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(title: self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(title: self.filterList[index].name)
            }
        }
    }
    
    @objc func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.shared.statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import GPUImage
import MultiSelectSegmentedControl

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.view.backgroundColor = UIColor.black
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:5.0,width:200.0,height:50.0))
        self.setLabelTitle(title: self.name)
        self.view.addSubview(label)
//        self.view.fillMode = GPUImageFillModeType.preserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.isHidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let font:UIFont = UIFont(name: "Helvetica-Bold", size: 18.0)!
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadow.shadowColor = UIColor.black
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.shadow : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
    }
}

class liveRestoreVC: UIViewController, MultiSelectSegmentedControlDelegate  {
    func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index)) as IndexSet
        }
        
        activeFilters = segment.selectedSegmentTitles
        fitViewsOntoScreen()
    }
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageStillCamera?
    var stillImageSource:GPUImagePicture?
    var cameraPosition: AVCaptureDevice.Position = .back
    var percent = 100
    var lastLocation:CGPoint = CGPoint(x:0, y:0)
    var viewState:Int = 0
   
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    enum ViewState: Int {
        case ViewAll = 0, FilterLabelsHidden, BottomBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    
        // Do any additional setup after loading the view, typically from a nib.
        
        segment.items = filterList.map{
            (filter) -> String in
            return filter.shortName
        }
        segment.selectedSegmentIndexes = NSIndexSet(index: 0) as IndexSet

        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.detectPan))
        self.view.gestureRecognizers = [panRecognizer]


        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:#selector(self.incrementViewState))
            
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }

        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(infoButton)

        self.fitViewsOntoScreen()

        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            cameraMagic(position: cameraPosition)
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(position: self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in UIView.setAnimationsEnabled(true) }

      UIView.setAnimationsEnabled(false)

      super.viewWillTransition(to: size, with: coordinator)
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame: frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        self.filterList = setHiddenOnFilterStructs(activeFilters: self.activeFilters)
        let videoViews = getVisibleFilterStructs(_filterList: filterList)
        
        filterList[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        filterList[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
        filterList[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
        filterList[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
        filterList[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)

        if(frame.height >= frame.width){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        case  2:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width, height: frame.height)
        case  3:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/3, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/3 * 2, width: frame.width, height: frame.height)
        case 4:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            videoViews[1].view.frame = CGRect(x: 0.0, y: frame.height/5, width: frame.width, height: frame.height)
            videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/5 * 2, width: frame.width, height: frame.height)
            videoViews[3].view.frame = CGRect(x: 0.0, y: frame.height/5 * 3, width: frame.width, height: frame.height)
            videoViews[4].view.frame = CGRect(x: 0.0, y: frame.height/5 * 4, width: frame.width, height: frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
            case  2:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/2, y: 0.0, width: frame.width, height: frame.height)
            case  3:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/3, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/3, y: 0.0, width: frame.width, height: frame.height)
            case 4:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[1].view.frame = CGRect(x: frame.width/2, y: 0.0, width: frame.width/2, height: frame.height/2)
                videoViews[2].view.frame = CGRect(x: 0.0, y: frame.height/2, width: frame.width/2, height: frame.height/2)
                videoViews[3].view.frame = CGRect(x: frame.width/2, y: frame.height/2, width: frame.width/2, height: frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
                videoViews[1].view.frame = CGRect(x: frame.width * 1/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[2].view.frame = CGRect(x: frame.width * 2/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[3].view.frame = CGRect(x: frame.width * 3/5, y: 0.0, width: frame.width, height: frame.height)
                videoViews[4].view.frame = CGRect(x: frame.width * 4/5, y: 0.0, width: frame.width, height: frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    @objc func incrementViewState(sender: AnyObject){

        self.viewState += 1
        
        switch (self.viewState){
        case ViewState.ViewAll.rawValue:
            bottomBar.isHidden = false
            infoButton.isHidden = false
            for filter in filterList{
                filter.label.isHidden = false
            }
        case ViewState.BottomBarHidden.rawValue:
            bottomBar.isHidden = true
            infoButton.isHidden = true
        case ViewState.FilterLabelsHidden.rawValue:
            for filter in filterList{
                filter.label.isHidden = true
            }
        default:
            self.viewState = -1
            incrementViewState(sender: self)
        }
        
        
  
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            })
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(hidden: true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(hidden: false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    

    func cameraMagic(position: AVCaptureDevice.Position){
        let orientation = UIApplication.shared.statusBarOrientation
        self.cameraMagic(position: position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevice.Position, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{

            let inputImage:UIImage = UIImage(imageLiteralResourceName: "test.jpg")
            stillImageSource = GPUImagePicture(image: inputImage)
            stillImageSource?.useNextFrameForImageCapture()


            for index in 0...(filterList.count - 1){
                stillImageSource?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.addTarget(self.filterList[index].view)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
            stillImageSource?.processImage()

        }
        
    }

    @IBAction func snapButtonTouchUpInside(_ sender: Any) {
        let view = containerView
        let viewImage:UIImage = view!.pb_takeSnapshot()
        saveImageToAlbum(image: viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRect(x: 0.0, y: 0.0, width: view!.bounds.width, height: view!.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRect(x: view!.bounds.width-40, y: view!.bounds.height, width: 40.0, height: 10.0 );
        tempView.genieInTransition(withDuration: 0.7, destinationRect: endRect, destinationEdge: BCRectEdge.top, completion: {
            tempView.removeFromSuperview()
        })
    }
    
    @IBAction func flipButtonTouchUpInside(_ sender: Any) {
        toggleCameraPosition()
        videoCamera?.stopCapture()
        cameraMagic(position: cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevice.Position.back){
            cameraPosition = AVCaptureDevice.Position.front
        }else{
            cameraPosition = AVCaptureDevice.Position.back
        }
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.location(in: containerView).y
        if recognizer.view != nil {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(title: self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(title: self.filterList[index].name)
            }
        }
    }
    
    @objc func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.shared.statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
    }

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
