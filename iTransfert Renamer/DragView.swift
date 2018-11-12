//
//  DragView.swift
//  iTransfert Renamer
//
//  Created by Mizaru on 01/11/2018.
//  Copyright © 2018 France Televisions. All rights reserved.
//

import Cocoa

protocol DragViewDelegate {
    func dragView(didDragFileWith URL: NSURL)
}

class DragView: NSView {
    
    var delegate: DragViewDelegate?
    //1
    private var fileTypeIsOk = false
    private var acceptedFileExtensions = ["aac","aif","aiff","avi","bmp","dxf","fla","flac","flv","ico","gif","jpg","jpeg","mov","mp2","mp3","mp4","mpg","mpeg","mxf","ogg","png","psd","raw","svg","tga","tif","tiff","vsd","wav","wma","wmv"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(forDraggedTypes: [NSFilenamesPboardType])
    }
    
    //2/
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        fileTypeIsOk = checkExtension(drag: sender)
        return []
    }
    
    //3
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return fileTypeIsOk ? .copy : []
    }
    
    //4
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let draggedFileURL = sender.draggedFileURL else {
            return false
        }
        
        //call the delegate
        if fileTypeIsOk {
            delegate?.dragView(didDragFileWith: draggedFileURL)
        }
        
        return true
    }
    
    //5
    fileprivate func checkExtension(drag: NSDraggingInfo) -> Bool {
        guard let fileExtension = drag.draggedFileURL?.pathExtension?.lowercased() else {
            return false
        }
        
        return acceptedFileExtensions.contains(fileExtension)
    }
    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }
    
}

//6
extension NSDraggingInfo {
    var draggedFileURL: NSURL? {
        let filenames = draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? [String]
        let path = filenames?.first
        return path.map(NSURL.init)
    }
}

