//
//  ImageProcessViewController.swift
//  imageCoreProcess
//
//  Created by 范志勇 on 2022/10/4.
//

import UIKit

class ImageProcessViewController: UIViewController {
    //MARK: hide status bar
    override var prefersStatusBarHidden: Bool {return true}
    
    var origionImageURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear

        // Do any additional setup after loading the view.
        self.title = ""
        
        // image container
        self.showContentView()
        
        // buttons
        self.createTopButtons()
        self.createBottomButtons()
    }
    
    var contentView: UIView!
    func showContentView() {
        self.contentView = UIView()
        self.contentView.backgroundColor = .black
        self.view.addSubview(self.contentView)
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let safe = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.contentView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            self.contentView.topAnchor.constraint(equalTo: safe.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
        ])
        
        // blur
        self.showOrigionImageWithBlur()

        // origional
        self.showOrigionImage()
    }
    
    var imageView_original: UIImageView!
    /// origional image
    ///
    /// Key
    /// - position: center
    /// - scale: scaleToFit
    func showOrigionImage() {
        print("showOrigionImage")
        
        guard let path = self.origionImageURL?.path else { return }
        let image = UIImage(contentsOfFile: path)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView)
        
        self.imageView_original = imageView
        
        // add gesture
        imageView.isUserInteractionEnabled = true
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchImage))
        imageView.addGestureRecognizer(pinch)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(draggingImage))
        imageView.addGestureRecognizer(pan)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        let safe = self.contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: safe.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
        ])
    }
    
    var scale: CGFloat = 1.0
    @objc func pinchImage(_ sender: UIPinchGestureRecognizer) {
        print("pinchImage")
        switch sender.state {
        case .began:
            break
            
        case .changed:
            DispatchQueue.main.async {
                let scale_tmp = self.scale * sender.scale
                self.imageView_original.transform = CGAffineTransform(scaleX: scale_tmp, y: scale_tmp)
            }
            
            break
            
        case .ended:
            self.scale *= sender.scale
            break
            
        default:
            break
        }
    }
    
    @objc func draggingImage(_ sender: UIPanGestureRecognizer) {
        print("draggingImage")
        
        let v = sender.view!
        switch sender.state {
        case .began, .changed:
            let delta = sender.translation(in:v.superview)
            var c = v.center
            c.x += delta.x; c.y += delta.y
            v.center = c
            sender.setTranslation(.zero, in: v.superview)
        default: break
        }
    }

    lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    var imageView_blur: UIImageView!
    func showOrigionImageWithBlur() {
        guard let path = self.origionImageURL?.path else { return }
        guard let originalImage = UIImage(contentsOfFile: path) else { return }
        
        //获取原始图片
        let inputImage =  CIImage(image: originalImage)
        //使用高斯模糊滤镜
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(inputImage, forKey:kCIInputImageKey)
        //设置模糊半径值（越大越模糊）
        filter.setValue(3, forKey: kCIInputRadiusKey)
        let outputCIImage = filter.outputImage!
        let rect = CGRect(origin: CGPoint.zero, size: originalImage.size)
        let cgImage = context.createCGImage(outputCIImage, from: rect)
        //显示生成的模糊图片
        
        let imageView = UIImageView()
        imageView.image = UIImage(cgImage: cgImage!)
        self.contentView.addSubview(imageView)
        
        self.imageView_blur = imageView
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let safe = self.contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: safe.centerYAnchor),
        ])
    }

    var button_Show_background: UIButton!
    var isShowBackground = true // show background
    
    func createTopButtons() {
        let aRect = CGRect(x: 0, y: 0, width: 100, height: 31)
        
        // Cancel
        let button_Cancel = UIButton(frame: aRect)
        button_Cancel.setTitle("Cancel", for: .normal)
        self.view.addSubview(button_Cancel)
        
        button_Cancel.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
        
        button_Cancel.translatesAutoresizingMaskIntoConstraints = false
        let safe = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            button_Cancel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 12),
            button_Cancel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
            button_Cancel.widthAnchor.constraint(equalToConstant: 100),
            button_Cancel.heightAnchor.constraint(equalToConstant: 31),
        ])
        
        // Show background
        let button_Show_background = UIButton(frame: aRect)
        button_Show_background.setTitle("Show background", for: .normal)
        let image = UIImage(systemName: "checkmark.square", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 17)))?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button_Show_background.setImage(image, for: .normal)
        self.view.addSubview(button_Show_background)
        self.button_Show_background = button_Show_background
        
        button_Show_background.addTarget(self, action: #selector(tapShowBackground), for: .touchUpInside)
        
        button_Show_background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button_Show_background.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
            button_Show_background.centerYAnchor.constraint(equalTo: button_Cancel.centerYAnchor),
            button_Show_background.widthAnchor.constraint(equalToConstant: 200),
            button_Show_background.heightAnchor.constraint(equalToConstant: 31),
        ])
    }
    
    @objc func closeWindow() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func tapShowBackground() {
        isShowBackground = !isShowBackground
        self.button_Show_background.isHidden = !isShowBackground
        
        if isShowBackground {
            // show
            self.imageView_blur.isHidden = false
        } else {
            // hidden
            self.imageView_blur.isHidden = true
        }
    }
    
    func createBottomButtons() {
        let aRect = CGRect(x: 0, y: 0, width: 100, height: 31)
        
        // Revert to origional
        let button_Restore = UIButton(frame: aRect)
        button_Restore.setTitle("Revert to Origional", for: .normal)
        button_Restore.setTitleColor(.systemGray, for: .normal)
        let image = UIImage(systemName: "arrow.clockwise", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 17)))?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        button_Restore.setImage(image, for: .normal)
        button_Restore.backgroundColor = .systemGroupedBackground
        button_Restore.layer.cornerRadius = 10
        
        self.view.addSubview(button_Restore)
        
        button_Restore.addTarget(self, action: #selector(revertToOrigional), for: .touchUpInside)
        
        button_Restore.translatesAutoresizingMaskIntoConstraints = false
        let safe = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            button_Restore.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
            button_Restore.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -12),
            button_Restore.widthAnchor.constraint(equalToConstant: 200),
            button_Restore.heightAnchor.constraint(equalToConstant: 31),
        ])
        
        // Save
        let button_Save = UIButton(frame: aRect)
        button_Save.setTitle("Save", for: .normal)
        self.view.addSubview(button_Save)
        
        button_Save.addTarget(self, action: #selector(save), for: .touchUpInside)
        
        button_Save.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button_Save.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
            button_Save.centerYAnchor.constraint(equalTo: button_Restore.centerYAnchor),
            button_Save.widthAnchor.constraint(equalToConstant: 80),
            button_Save.heightAnchor.constraint(equalToConstant: 31),
        ])
    }
    
    @objc func revertToOrigional() {
        self.imageView_original.isHidden = true
        self.imageView_original.removeFromSuperview()
        
        self.showOrigionImage()
    }
    
    @objc func save() {
        let renderer = UIGraphicsImageRenderer(size: self.view.bounds.size)
        let viewImage = renderer.image { ctx in
            self.contentView.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        }

        // save in photo album
        UIImageWriteToSavedPhotosAlbum(viewImage,self,nil,nil)
        
        let data = viewImage.pngData()
        // 存储
        do {
            let foldername = "png"
            let fm = FileManager.default
            let docsurl = try fm.url(for:.applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let myfolder = docsurl.appendingPathComponent(foldername)
            
            try fm.createDirectory(at:myfolder, withIntermediateDirectories: true)
            let fileName = "saved" + ".png"
            let fileURL = myfolder.appendingPathComponent(fileName)
            try data?.write(to: fileURL)
        }  catch let err as NSError {
            print("Error: \(err.domain)")
        }
    }

}
