//
//  RenderViewController.swift
//  Diveroid300
//
//  Created by diveroid on 2022/11/12.
//
import UIKit
import GPUImage
import AVFoundation
import PhotosUI


import CoreMedia


import Photos

import Foundation


class MovieViewController: UIViewController {
    
    
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        print("init MovieViewController")
    }
    
    deinit {
        print("deinit MovieViewController")
    }
    
    
    
    @IBOutlet weak var renderView: RenderView!
    
    var picture : PictureInput!;
    var movie:MovieInput!
    var audio: AudioInput!
    var prefilter : RGBSampleAdjustment!
    var filter:WaterAdjustment!
    
    var movieOutput : MovieOutput?
    
    
    @IBOutlet weak var mRenderView: RenderView!
    
    @IBOutlet var mView: UIView!
   

    var imagePickerController = UIImagePickerController()
    var videoURL: URL?
    var videoWIDTH = 0;
    var videoHEIGHT = 0;
    var videoThumbnail :UIImage?;
    var videoDuration : CMTime?;
    
    
    var savingFileURL: URL?
    
    static var selectedAsset: PHAsset!
    static var selectedAssetImage : UIImage!
    
    
    public var parentVC: NewColorFilterViewController?
    
    
    var vSpinner : UIView?
    var vSpinerProgress : UIButton?
    
    var timer: Timer?
    var count = 0
   
    private var fileNamePrefix:String = "prefix_";
    


    var isDownOrigin : Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        renderView?.isReverse = false;
        //let value = UIInterfaceOrientation.portrait.rawValue
        //UIDevice.current.setValue(value, forKey: "orientation")
        
        //상단 타이틀 바를 없앤다.
        self.navigationController?.navigationBar.isHidden = true
        //self.navigationController?.navigationBar.barStyle = .blackOpaque;//.black;
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        
        if( movie != nil )
        {
            movie.cancel();
        }
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        //자동 화면 꺼짐 옛날 상태로 돌린다.
        UIApplication.shared.isIdleTimerDisabled = oldIsIdleTimerDisabled!;
        
        stopTimer()
        
        
        renderView?.stopTimer()
        renderView?.videoEncodingTarget = nil
        clearFiltStream();
        
        
        //자식 컨트롤들 다 제거 해야 한다.
        for sview in self.children {
            sview.removeFromParent()
        }
        
        for sview in self.view.subviews {
            sview.removeFromSuperview()
        }
        
        
        movieViewPrepareController? .movieViewController  = nil
        movieViewPlayController? .movieViewController  = nil
        movieViewRecordController? .movieViewController  = nil
        movieViewRecordDoneController? .movieViewController  = nil
        
        movieViewImageController? .movieViewController  = nil
        movieViewImageDoneController?.movieViewController  = nil
        
        
        movieViewPrepareController = nil
        movieViewPlayController = nil
        movieViewRecordController = nil
        movieViewRecordDoneController = nil
        
        movieViewImageController  = nil
        movieViewImageDoneController = nil
        
        
        
        
      
        
    }
    
    
    func clearFiltStream()
    {
        filter?.removeAllTargets()
        prefilter?.removeAllTargets()
        picture?.stopTimer();
        picture?.removeAllTargets()
        movie?.removeAllTargets()
        movie?.cancel();
        
        
        filter = nil
        prefilter = nil
        picture = nil
        movie = nil
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
        
        
        //        let bundleURL = Bundle.main.resourceURL!
        //        let movieURL = URL(string:"sample_iPod.m4v", relativeTo:bundleURL)!
        //
        //        do {
        //            movie = try MovieInput(url:movieURL, playAtActualSpeed:true)
        //            filter = Pixellate()
        //            movie --> filter --> renderView
        //            movie.runBenchmark = true
        //            movie.start()
        //        } catch {
        //            print("Couldn't process movie with error: \(error)")
        //        }
        
        //            let documentsDir = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain:.UserDomainMask, appropriateForURL:nil, create:true)
        //            let fileURL = NSURL(string:"test.png", relativeToURL:documentsDir)!
        //            try pngImage.writeToURL(fileURL, options:.DataWritingAtomic)
    }
}
