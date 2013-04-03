package org.glob3.mobile.generated; 
//
//  Vector2D.cpp
//  G3MiOSSDK
//
//  Created by Diego Gomez Deck on 31/05/12.
//  Copyright (c) 2012 IGO Software SL. All rights reserved.
//

//
//  Vector2D.hpp
//  G3MiOSSDK
//
//  Created by Diego Gomez Deck on 31/05/12.
//  Copyright (c) 2012 IGO Software SL. All rights reserved.
//




//class MutableVector2D;

public class Vector2D
{


//C++ TO JAVA CONVERTER TODO TASK: The implementation of the following method could not be found:
//  Vector2D operator =(Vector2D v);

  public final double _x;
  public final double _y;

  public static Vector2D zero()
  {
    return new Vector2D(0, 0);
  }

  public Vector2D(double x, double y)
  {
     _x = x;
     _y = y;

  }

  public Vector2D(Vector2D v)
  {
     _x = v._x;
     _y = v._y;

  }

//C++ TO JAVA CONVERTER TODO TASK: The implementation of the following method could not be found:
//  Vector2D normalized();

  public final double length()
  {
    return IMathUtils.instance().sqrt(squaredLength());
  }

  public final Angle orientation()
  {
     return Angle.fromRadians(IMathUtils.instance().atan2(_y, _x));
  }

  public final double squaredLength()
  {
    return _x * _x + _y * _y;
  }

  public final Vector2D add(Vector2D v)
  {
    return new Vector2D(_x + v._x, _y + v._y);
  }

  public final Vector2D sub(Vector2D v)
  {
    return new Vector2D(_x - v._x, _y - v._y);
  }

  public final Vector2D times(Vector2D v)
  {
    return new Vector2D(_x * v._x, _y * v._y);
  }

  public final Vector2D times(double magnitude)
  {
    return new Vector2D(_x * magnitude, _y * magnitude);
  }

  public final Vector2D div(Vector2D v)
  {
    return new Vector2D(_x / v._x, _y / v._y);
  }

  public final Vector2D div(double v)
  {
    return new Vector2D(_x / v, _y / v);
  }

  public final Angle angle()
  {
    double a = IMathUtils.instance().atan2(_y, _x);
    return Angle.fromRadians(a);
  }

  public final double x()
  {
    return _x;
  }

  public final double y()
  {
    return _y;
  }

  public static Vector2D nan()
  {
    final IMathUtils mu = IMathUtils.instance();

    return new Vector2D(mu.NanD(), mu.NanD());
  }

  public final double maxAxis()
  {
    return (_x >= _y) ? _x : _y;
  }

  public final double minAxis()
  {
    return (_x <= _y) ? _x : _y;
  }

  public final MutableVector2D asMutableVector2D()
  {
    return new MutableVector2D(_x, _y);
  }

  public final boolean isNan()
  {
//    return IMathUtils::instance()->isNan(_x) || IMathUtils::instance()->isNan(_y);

    if (_x != _x)
    {
      return true;
    }
    if (_y != _y)
    {
      return true;
    }
    return false;
  }

  public final String description()
  {
    IStringBuilder isb = IStringBuilder.newStringBuilder();
    isb.addString("(V2D ");
    isb.addDouble(_x);
    isb.addString(", ");
    isb.addDouble(_y);
    isb.addString(")");
    final String s = isb.getString();
    if (isb != null)
       isb.dispose();
    return s;
  }

}