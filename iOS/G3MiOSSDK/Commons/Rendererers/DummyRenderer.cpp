//
//  DummyRenderer.cpp
//  Glob3 Mobile
//
//  Created by Agustín Trujillo Pino on 02/05/11.
//  Copyright 2011 Universidad de Las Palmas. All rights reserved.
//

#include "DummyRenderer.hpp"

#include "Context.hpp"
#include "GL.hpp"
#include "Planet.hpp"
#include "Vector3D.hpp"

#include "FloatBufferBuilderFromCartesian3D.hpp"
#include "ShortBufferBuilder.hpp"
#include "IShortBuffer.hpp"

DummyRenderer::~DummyRenderer() {
  delete _indices;
  delete _vertices;
}

void DummyRenderer::initialize(const G3MContext* context) {
  int res = 12;
  
  FloatBufferBuilderFromCartesian3D vertices(CenterStrategy::noCenter(), Vector3D::zero());
  ShortBufferBuilder index;
  
  // create vertices
  
  if (context != NULL && context->getPlanet() != NULL) {
    _halfSize = context->getPlanet()->getRadii()._x / 2.0;
  }
  else {
    _halfSize = 7e6;
  }
  
  for (int j = 0; j < res; j++) {
    for (int i = 0; i < res; i++) {
      
      vertices.add((float)0,
                   (float)(-_halfSize + i / (float) (res - 1) * 2*_halfSize),
                   (float)(+_halfSize - j / (float) (res - 1) * 2*_halfSize));
    }
  }
  
  for (int j = 0; j < res - 1; j++) {
    if (j > 0){
      index.add((short) (j * res));
    }
    for (int i = 0; i < res; i++) {
      index.add((short) (j * res + i));
      index.add((short) (j * res + i + res));
    }
    index.add((short) (j * res + 2 * res - 1));
  }
  
  _indices = index.create();
  _vertices = vertices.create();
}


bool DummyRenderer::onTouchEvent(const G3MEventContext* ec,
                                 const TouchEvent* touchEvent){
  return false;
}

void DummyRenderer::drawFace(GL* gl, const GLState& parentState,
                             const Color& color, const Vector3D& translation, const Angle& a,
                             const Vector3D& rotationAxis, GPUProgramManager &manager,
                             const GPUProgramState* gpuParentProgramState) const
{
  GLState state(parentState);
  
  state.enableFlatColor(color, (float)1.0);
  MutableMatrix44D T = MutableMatrix44D::createTranslationMatrix(translation);
  MutableMatrix44D R = MutableMatrix44D::createRotationMatrix(a, rotationAxis);
  
  state.multiplyModelViewMatrix(T.multiply(R));
  gl->drawElements(GLPrimitive::triangleStrip(), _indices, state, manager, gpuParentProgramState);
}

void DummyRenderer::render(const G3MRenderContext* rc,
                           const GLState& parentState) {
  
  GPUProgramState progState(NULL);
  
  GLState state(parentState);
  state.enableVerticesPosition();
  state.setVertices(_vertices, 3, 0);
  GL* gl = rc->getGL();
  GPUProgramManager* manager = rc->getGPUProgramManager();
  drawFace(gl, state,
           Color::fromRGBA((float) 1,(float)  0, (float) 0, (float) 1),
           Vector3D(_halfSize,0,0),
           Angle::fromDegrees(0), Vector3D(0,0,1), manager, &progState);
  
  drawFace(gl, state,
           Color::fromRGBA((float) 0,(float)  1, (float) 0, (float) 1),
           Vector3D(0,_halfSize,0),
           Angle::fromDegrees(90), Vector3D(0,0,1), manager, &progState);
  
  drawFace(gl, state,
           Color::fromRGBA((float) 0,(float)  0, (float) 1, (float) 1),
           Vector3D(0,-_halfSize,0),
           Angle::fromDegrees(-90), Vector3D(0,0,1), manager, &progState);
  
  drawFace(gl, state,
           Color::fromRGBA((float) 1,(float)  0, (float) 1, (float) 1),
           Vector3D(0,0,-_halfSize),
           Angle::fromDegrees(90), Vector3D(0,1,0), manager, &progState);
  
  drawFace(gl, state,
           Color::fromRGBA((float) 0,(float) 1, (float) 1, (float) 1),
           Vector3D(0,0,_halfSize),
           Angle::fromDegrees(-90), Vector3D(0,1,0), manager, &progState);
  
  drawFace(gl, state,
           Color::fromRGBA((float) 0.5,(float)  0.5, (float) 0.5, (float) 1),
           Vector3D(-_halfSize,0,0),
           Angle::fromDegrees(180), Vector3D(0,0,1), manager, &progState);
}
