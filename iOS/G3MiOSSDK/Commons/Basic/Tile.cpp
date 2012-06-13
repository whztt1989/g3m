//
//  Tile.cpp
//  G3MiOSSDK
//
//  Created by Agustín Trujillo Pino on 12/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>

#include "Tile.h"
#include "Angle.hpp"
#include "Geodetic3D.hpp"
#include "Vector3D.hpp"
#include "Camera.hpp"

unsigned int Tile::numIndices = 0;
unsigned int Tile::numBorderIndices = 0;
unsigned int Tile::numInnerIndices = 0;
unsigned char *Tile::indices = NULL;
unsigned char *Tile::borderIndices = NULL;
unsigned char *Tile::innerIndices = NULL;
unsigned int Tile::_resolution;
bool Tile::_skirts;


Tile::~Tile()
{
  if (!vertexCoor) delete[] vertexCoor;
}


void Tile::createVertices(const Planet *planet) 
{
  Angle maxLat = BBox.max().latitude(), minLat = BBox.min().latitude();
  Angle minLon = BBox.min().longitude(), maxLon = BBox.max().longitude();
  //Globe *globe = SceneController::GetInstance()->getGlobe();
  //Ellipsoid *ellipsoid = globe->GetEllipsoid();
  //bool skirts = globe->SkirtedTiles();
  
  int resol = _resolution;
  int resol2 = resol * resol;
  int n1 = _resolution - 1;
  //double exag = globe->GetExagElevFactor();
  double maxH = 0, H;
  Angle latSize = maxLat.sub(minLat);
  Angle lonSize = maxLon.sub(minLon);
  const double sizeSkirt = 0.95;
  
  // compute number of vertices in the mesh (there are less vertices if the tiles touches one of the poles) 
  unsigned int numVertices = resol2;
  if (_skirts) numVertices += 4 * resol - 4;
  
  // if first time for tile, alloc memory
  if (vertexCoor == NULL) {
    vertexCoor = new float[numVertices * 3];
    //textureCoor = new float[numVertices * 2];
  }
  
  // alloc temp memory to create a matrix of coordinates
  double *x = new double[resol2];
  double *y = new double [resol2];
  double *z = new double [resol2];
  float *u = new float[resol2];
  float *v = new float [resol2];
  
  // create mesh coordinates
  for (int j = 0; j < resol; j++)
    for (int i = 0; i < resol; i++) {
      unsigned int pos = j * resol + i;
      //H = (elev != NULL) ? elev[pos] * exag : 0;
      H = 0.0;
      if (H > maxH) maxH = H;
      //lat = (maxLat.value - latSize.value*j/n1);
      //lon = (minLon.value + lonSize.value*i/n1);
      Angle lat = Angle::fromDegrees((maxLat.degrees() - latSize.degrees() * j / n1));
      Angle lon = Angle::fromDegrees((minLon.degrees() + lonSize.degrees() * i / n1));
      Geodetic3D g3(lat, lon, H);
      Vector3D P = planet->toVector3D(g3);
      x[pos] = P.x();
      y[pos] = P.y();
      z[pos] = P.z();
      u[pos] = (float) i / n1;
      v[pos] = (float) j / n1;
    }
  
  // compute center of tile
  Angle lat = Angle::fromDegrees((minLat.degrees() + maxLat.degrees()) / 2);
  Angle lon = Angle::fromDegrees((minLon.degrees() + maxLon.degrees()) / 2);
  Geodetic3D g3(lat, lon, maxH);
  Vector3D center = planet->toVector3D(g3);
  
  
  // AGUSTIN NOTE: THIS IS TEMPORARY
  centerx = center.x();
  centery = center.y();
  centerz = center.z();
  
  // create a nxn mesh 
  unsigned int posV = 0;
  //unsigned int posT = 0;
  for (int j = 0; j < resol; j++)
    for (int i = 0; i < resol; i++) {
      unsigned int pos = j * resol + i;
      vertexCoor[posV++] = (float) (x[pos] - center.x());
      vertexCoor[posV++] = (float) (y[pos] - center.y());
      vertexCoor[posV++] = (float) (z[pos] - center.z());
      //textureCoor[posT++] = u[pos];
      //textureCoor[posT++] = v[pos];
    }
  
  // create skirts 
  if (_skirts) {
    
    // west side
    for (int j = 0; j < resol - 1; j++) {
      unsigned int pos = j * resol;
      vertexCoor[posV++] = (float) (x[pos] * sizeSkirt - center.x());
      vertexCoor[posV++] = (float) (y[pos] * sizeSkirt - center.y());
      vertexCoor[posV++] = (float) (z[pos] * sizeSkirt - center.z());
      //textureCoor[posT++] = u[pos];
      //textureCoor[posT++] = v[pos];
    }
    
    // south side
    for (int i = 0; i < resol - 1; i++) {
      unsigned int pos = (resol - 1) * resol + i;
      vertexCoor[posV++] = (float) (x[pos] * sizeSkirt - center.x());
      vertexCoor[posV++] = (float) (y[pos] * sizeSkirt - center.y());
      vertexCoor[posV++] = (float) (z[pos] * sizeSkirt - center.z());
      //textureCoor[posT++] = u[pos];
      //textureCoor[posT++] = v[pos];
    }
    
    // east side
    for (int j = resol - 1; j > 0; j--) {
      unsigned int pos = j * resol + resol - 1;
      vertexCoor[posV++] = (float) (x[pos] * sizeSkirt - center.x());
      vertexCoor[posV++] = (float) (y[pos] * sizeSkirt - center.y());
      vertexCoor[posV++] = (float) (z[pos] * sizeSkirt - center.z());
      //textureCoor[posT++] = u[pos];
      //textureCoor[posT++] = v[pos];
    }
    
    // north side
    for (int i = resol - 1; i > 0; i--) {
      unsigned int pos = i;
      vertexCoor[posV++] = (float) (x[pos] * sizeSkirt - center.x());
      vertexCoor[posV++] = (float) (y[pos] * sizeSkirt - center.y());
      vertexCoor[posV++] = (float) (z[pos] * sizeSkirt - center.z());
      //textureCoor[posT++] = u[pos];
      //textureCoor[posT++] = v[pos];
    }
  }
  
  // free temp memory
  delete[] x;
  delete[] y;
  delete[] z;
  delete[] u;
  delete[] v;
}


void Tile::deleteIndices()
{
  if (indices) {
    delete[] indices;
    indices = NULL;
    numIndices = 0;
  }
  if (innerIndices) {
    delete[] innerIndices;
    innerIndices = NULL;
    numInnerIndices = 0;
  }
  if (borderIndices) {
    delete[] borderIndices;
    borderIndices = NULL;
    numBorderIndices = 0;
  }
}


void Tile::createIndices(unsigned int resol, bool skirts) 
{
  _resolution = resol;
  _skirts = skirts;
  
  // alloc memory 
  numIndices = (resol - 1) * (2 * resol + 2) - 1; //remove the first degenerated vertex
  if (skirts) numIndices += 8 * resol - 4;
  indices = new unsigned char[numIndices];
  
  // create indices vector for the mesh
  unsigned int posI = 0;
  for (int j = 0; j < resol - 1; j++) {
    if (j > 0) indices[posI++] = (unsigned char) (j * resol);
    for (int i = 0; i < resol; i++) {
      indices[posI++] = (unsigned char) (j * resol + i);
      indices[posI++] = (unsigned char) (j * resol + i + resol);
    }
    indices[posI++] = (unsigned char) (j * resol + 2 * resol - 1);
  }
  
  // create skirts 
  if (skirts) {
    indices[posI++] = 0;
    unsigned int posS = resol * resol;
    
    // west side
    for (int j = 0; j < resol - 1; j++) {
      unsigned int pos = j * resol;
      indices[posI++] = (unsigned char) (pos);
      indices[posI++] = (unsigned char) (posS++);
    }
    
    // south side
    for (int i = 0; i < resol - 1; i++) {
      unsigned int pos = (resol - 1) * resol + i;
      indices[posI++] = (unsigned char) pos;
      indices[posI++] = (unsigned char) (posS++);
    }
    
    // east side
    for (int j = resol - 1; j > 0; j--) {
      unsigned int pos = j * resol + resol - 1;
      indices[posI++] = (unsigned char) (pos);
      indices[posI++] = (unsigned char) (posS++);
    }
    
    // north side
    for (int i = resol - 1; i > 0; i--) {
      unsigned int pos = i;
      indices[posI++] = (unsigned char) pos;
      indices[posI++] = (unsigned char) (posS++);
    }
    
    // last triangles
    indices[posI++] = (unsigned char) 0;
    indices[posI++] = (unsigned char) (resol * resol);
    indices[posI++] = (unsigned char) (resol * resol);
  }
  
  // create border indices (wireframe mode)
  numBorderIndices = 4 * (resol - 1);
  borderIndices = new unsigned char[numBorderIndices];
  posI = 0;
  for (int j = 0; j < resol - 1; j++) borderIndices[posI++] = (unsigned char) (j * resol);
  for (int i = 0; i < resol - 1; i++) borderIndices[posI++] = (unsigned char) ((resol - 1) * resol + i);
  for (int j = resol - 1; j > 0; j--) borderIndices[posI++] = (unsigned char) (j * resol + resol - 1);
  for (int i = resol - 1; i > 0; i--) borderIndices[posI++] = (unsigned char) (i);
  
  // create inner indices (wireframe mode)
  numInnerIndices = numBorderIndices * (resol - 2);
  innerIndices = new unsigned char[numInnerIndices];
  posI = 0;
  for (int j = 1; j < resol - 1; j++)
    for (int i = 0; i < resol - 1; i++) {
      int pos = j * resol + i;
      innerIndices[posI++] = (unsigned char) pos;
      innerIndices[posI++] = (unsigned char) (pos + 1);
    }
  for (int i = 1; i < resol - 1; i++)
    for (int j = 0; j < resol - 1; j++) {
      int pos = j * resol + i;
      innerIndices[posI++] = (unsigned char) pos;
      innerIndices[posI++] = (unsigned char) (pos + resol);
    }
}



void Tile::render(const RenderContext* rc)
{
  // obtain the gl object
  IGL *gl = rc->getGL();
  
  // compute the matriz centered on the tile  
  MutableMatrix44D lookAt = rc->getCamera()->getModelMatrix();
  double M[16];
  for (int i = 0; i < 16; i++) M[i] = lookAt.get(i);
  M[12] += M[0] * centerx + M[4] * centery + M[8] * centerz;
  M[13] += M[1] * centerx + M[5] * centery + M[9] * centerz;
  M[14] += M[2] * centerx + M[6] * centery + M[10] * centerz;
  float Mf[16];
  for (int k = 0; k < 16; k++) Mf[k] = (float) M[k];
  gl->loadMatrixf(Mf);

  // set opengl texture and pointers
  //gl->BindTexture(idTexture);
  gl->vertexPointer(3, 0, vertexCoor);
  //gl->TexCoordPointer(2, 0, textureCoor);
  gl->color(0.5,0.5,0.8);
  
  // draw tile geometry
  if (true /*g->GetWireframe()*/) {
    
    // draw solid mesh
    gl->enablePolygonOffset(5, 5);
    gl->drawTriangleStrip(numIndices, indices);
    gl->disablePolygonOffset();
    
    // draw wireframe
    //gl->disableTexture2D();
    //gl->disableTextures();
    gl->lineWidth(1);
    gl->color(0.0f, 0.0f, 0.0f);
    gl->drawLines(numInnerIndices, innerIndices);
    gl->lineWidth(2);
    gl->color(1.0f, 0.0f, 0.0f);
    gl->drawLineLoop(numBorderIndices, borderIndices);
    //gl->EnableTextures();
    //gl->EnableTexture2D();
    
  } else {
    
    // draw the mesh
    gl->drawTriangleStrip(numIndices, indices);
  }
}

