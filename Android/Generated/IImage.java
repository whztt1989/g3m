package org.glob3.mobile.generated; 
//
//  IImage.h
//  G3MiOSSDK
//
//  Created by José Miguel S N on 01/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


public abstract class IImage
{
  public abstract void loadFromFileName(String filename);

  // a virtual destructor is needed for conversion to Java
  public void dispose()
  {
  }
}