//
//  ViewController.swift
//  MelfImageProcess
//
//  Created by 范志勇 on 2022/10/4.
//

import UIKit
import MobileCoreServices
import Photos
import PhotosUI
import AVKit
import ImageIO

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func processImage1(_ sender: UIButton) {
        let imageFileName = "bee"
        let ext = "jpg"
        
        guard let imageURL = Bundle.main.url(forResource: imageFileName, withExtension: ext) else {
            return
        }
        
        let vc = ImageProcessViewController()
        vc.origionImageURL = imageURL

        // full screen
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func loadImage(_ sender: UIButton) {
        let src = UIImagePickerController.SourceType.photoLibrary
        guard UIImagePickerController.isSourceTypeAvailable(src) else {return}
        guard let arr = UIImagePickerController.availableMediaTypes(for:src) else {return}
        let picker = UIImagePickerController()
        picker.sourceType = src
        picker.mediaTypes = arr
        picker.delegate = self
        picker.videoExportPreset = AVAssetExportPreset640x480 // or whatever
        self.present(picker, animated: true)
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // this has no effect
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return .landscape
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { //
        print("====== pick!")
        let mediatype = info[.mediaType]
        print("media type:", mediatype as Any)
        let asset = info[.phAsset] as? PHAsset
        print("asset:", asset as Any)
        print("playbackstyle:", asset?.playbackStyle.rawValue as Any)
        // types are 0 for unsupported, then image, imageAnimated, livePhoto, video, videoLooping
        let url = info[.mediaURL] as? URL
        print("media url:", url as Any)
        var im = info[.originalImage] as? UIImage
        print("original image:", im as Any)
        if let ed = info[.editedImage] as? UIImage {
            im = ed
        }
        let live = info[.livePhoto] as? PHLivePhoto
        print("live:", live as Any)
        let imurl = info[.imageURL] as? URL
        print("image url:", imurl as Any)
        self.dismiss(animated:true) {
            if imurl != nil {
                let vc = ImageProcessViewController()
                vc.origionImageURL = imurl

                // full screen
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
            
        }
    }
    
}
