package org.glob3.mobile.generated; 
//
//  SingleImageTileTexturizer.cpp
//  G3MiOSSDK
//
//  Created by José Miguel S N on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//
//  SingleImageTileTexturizer.hpp
//  G3MiOSSDK
//
//  Created by José Miguel S N on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//





public class SingleImageTileTexturizer extends TileTexturizer
{

  private RenderContext _renderContext;
  private final TilesRenderParameters _parameters;
  private GLTextureID _texID = new GLTextureID();
  private final IImage _image;

//C++ TO JAVA CONVERTER WARNING: 'const' methods are not available in Java:
//ORIGINAL LINE: java.util.ArrayList<MutableVector2D> createTextureCoordinates(const RenderContext* rc, Mesh* mesh) const
  private java.util.ArrayList<MutableVector2D> createTextureCoordinates(RenderContext rc, Mesh mesh)
  {
	java.util.ArrayList<MutableVector2D> texCoors = new java.util.ArrayList<MutableVector2D>();
  
	for (int i = 0; i < mesh.getVertexCount(); i++)
	{
  
	  Vector3D pos = mesh.getVertex(i);
  
	  final Geodetic2D g = rc.getPlanet().toGeodetic2D(pos);
	  final Vector3D n = rc.getPlanet().geodeticSurfaceNormal(g);
  
	  final double s = Math.atan2(n.y(), n.x()) / (Math.PI * 2) + 0.5;
	  final double t = Math.asin(n.z()) / Math.PI + 0.5;
  
	  texCoors.add(new MutableVector2D(s, 1-t));
	}
  
	return texCoors;
  }


  public SingleImageTileTexturizer(TilesRenderParameters parameters, IImage image)
  {
	  _texID = new GLTextureID(-1);
	  _image = image;
	  _parameters = parameters;
	  _renderContext = null;
  }

  public void dispose()
  {
	if (_texID.isValid())
	{
	  if (_renderContext != null)
	  {
		_renderContext.getTexturesHandler().releaseGLTextureId(_texID);
	  }
	}
  }

  public final void initialize(InitializationContext ic, TilesRenderParameters parameters)
  {

  }

  public final Mesh texturize(RenderContext rc, TileRenderContext trc, Tile tile, Mesh mesh, Mesh previousMesh)
  {
	_renderContext = rc; //SAVING CONTEXT
  
	if (!_texID.isValid())
	{
	  _texID = rc.getTexturesHandler().getGLTextureId(_image, new TextureSpec("SINGLE_IMAGE_TEX", _image.getWidth(), _image.getHeight()));
  
	  if (!_texID.isValid())
	  {
		rc.getLogger().logError("Can't upload texture to GPU");
		return null;
	  }
  
	  rc.getFactory().deleteImage(_image);
	}
  
	TextureMapping texMap = new SimpleTextureMapping(_texID, createTextureCoordinates(rc, mesh));
	if (previousMesh != null)
		if (previousMesh != null)
			previousMesh.dispose();
  
	tile.setTextureSolved(true);
	tile.setTexturizerDirty(false);
  
	return new TexturedMesh(mesh, false, texMap, true);
  }

  public final void tileToBeDeleted(Tile tile, Mesh mesh)
  {
  
  }

  public final boolean tileMeetsRenderCriteria(Tile tile)
  {
	return false;
  }

  public final void justCreatedTopTile(RenderContext rc, Tile tile)
  {
  
  }

  public final boolean isReady(RenderContext rc)
  {
	return true;
  }

  public final void ancestorTexturedSolvedChanged(Tile tile, Tile ancestorTile, boolean textureSolved)
  {
  
  }

  public final void onTerrainTouchEvent(Geodetic3D g3d, Tile tile)
  {
  }


  public final void tileMeshToBeDeleted(Tile tile, Mesh mesh)
  {
  
  }

}