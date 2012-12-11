//
//  PanoDownloadListener.hpp
//  G3MiOSSDK
//
//  Created by Eduardo de la Montaña on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef G3MiOSSDK_PanoDownloadListener_hpp
#define G3MiOSSDK_PanoDownloadListener_hpp

#include "IBufferDownloadListener.hpp"
#include "ILogger.hpp"
#include "JSONObject.hpp"
#include "MarkTouchListener.hpp"

class MarksRenderer;
class PanoDownloadListener : public IBufferDownloadListener {
    
    static const std::string NAME;
    static const std::string POSITION;
    static const std::string LAT;
    static const std::string LON;
    
    MarksRenderer* _marksRenderer;
    MarkTouchListener* _panoTouchListener;
    
public:
    PanoDownloadListener(MarksRenderer* _marksRenderer, MarkTouchListener* panoTouchListener);
    
    void onDownload(const URL& url,
                    const IByteBuffer* buffer);
    
    void onError(const URL& url){
        ILogger::instance()->logError("The requested pano could not be found!");    
    }
    
    void onCancel(const URL& url){}
    void onCanceledDownload(const URL& url,
                            const IByteBuffer* data) {}
    
    ~PanoDownloadListener(){}
private:
    void parseMETADATA(std::string url, JSONObject* jsonCustomData);
};

#endif
