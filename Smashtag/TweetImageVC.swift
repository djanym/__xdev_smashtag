//
//  TweetImageVC.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/18.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit

class TweetImageVC: UIViewController {
	
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	@IBOutlet weak var scroll: UIScrollView! {
		didSet {
			// to zoom we have to handle viewForZooming(in scrollView:)
			scroll.delegate = self
			// most important thing to set in UIScrollView is contentSize
			scroll.contentSize = imageView.frame.size
			scroll.addSubview(imageView)
		}
	}
	
	// наша Model
	// устанавливается извне (publicly)
	// если она меняется (но только если мы на экране)
	//   делаем выборку image по imageURL
	// если мы не на экране, когда это происходит (view.window == nil)
	//   viewWillAppear будет делать это за нас позже
	var imageURL: URL? {
		didSet {
			guard let imageURL = imageURL else { return }
			image = nil
			if view.window != nil {
				fetchImage(from: imageURL)
			}
		}
	}
	
	fileprivate var imageView = UIImageView()
	fileprivate var autoZoomed = true
	
	var image: UIImage? {
		get {
			return imageView.image
		}
		set {
			imageView.image = newValue
			imageView.sizeToFit()
			// careful here because scrollView might be nil
			// (for example, if we're setting our image as part of a prepare)
			// so use optional chaining to do nothing
			// if our scrollView outlet has not yet been set
			scroll?.contentSize = imageView.frame.size
			autoZoomed = true
			defaultScaleZoom()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		self.navigationItem.title = "Imagezz" // also works
		self.title = "Image view"
		self.navigationItem.hidesBackButton = false
		self.navigationItem.backBarButtonItem?.title = "Backkk"
	}
	
	// для эффективности мы будем осуществлять актуальную выборку image
	// когда мы точно знаем, что появимся на экране
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if image == nil, let imageURL = imageURL {
			fetchImage(from: imageURL)
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		defaultScaleZoom()
	}
	
	private func fetchImage(from url: URL){
		spinner?.startAnimating()
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			// For test purposes
			usleep(1000000)
			
			let contentsOfURL = try? Data(contentsOf: url)
			if let imageData = contentsOfURL  {
				DispatchQueue.main.async {
					guard url == self?.imageURL else { return }
					self?.spinner?.stopAnimating()
					self?.image = UIImage(data: imageData)
				}
			}
		}
	}
	
	private func defaultScaleZoom(){
		if scroll != nil && image != nil && autoZoomed {
			let xZoomScale = scroll.bounds.size.width / imageView.bounds.size.width
			let yZoomScale = scroll.bounds.size.height / imageView.bounds.size.height
			
			//set minimumZoomScale to the minimum zoom scale we calculated
			//this mean that the image cant me smaller than full screen
			scroll.minimumZoomScale = min(xZoomScale,yZoomScale);
			//and not larger than 10 or maxZoomScaleallow up to 4x zoom
			scroll.maximumZoomScale = max(xZoomScale,yZoomScale,10);
			//set the starting zoom scale
			scroll.zoomScale = scroll.minimumZoomScale
			//imageView.center = scrollView.center
		}
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UIScrollViewDelegate
// Extension which makes ImageViewController conform to UIScrollViewDelegate
// Handles viewForZooming(in scrollView:)
// by returning the UIImageView as the view to transform when zooming
extension TweetImageVC : UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	// Убираем автоматическую "подгонку" после того, как пользователь выполняет zoom
	// с помощью жеста pinching
	func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
		autoZoomed = false
	}
}
