/** @jsx jsx */

import React, {
  useRef, useState, useCallback, useEffect, useMemo
} from 'react';
import { jsx, css } from '@emotion/react';
import ReactMapGL, { Source, Layer, NavigationControl, Popup } from 'react-map-gl';
import Geocoder from 'react-map-gl-geocoder';

const navigationStyle = css`
  bottom: 4.2rem;
  position: absolute;
  right: 1rem;
`;

const popupStyle = css`
  padding: 0 0.4rem;
  .popup-muni {
    // text-transform: lowercase;
  }
  h1 {
      font-size: 1.8rem;
  }
  h2 {
    font-size: 1.4rem;
  }
`;

const inputStyle = css`
  z-index: 2;
`;

const Subregions = () => {
  const mapRef: any = useRef();

  useEffect(() => {
    if (mapRef && mapRef.current) {
      const map = mapRef.current.getMap();

    }
  }, []);

  const [viewport, setViewport] = useState({
    latitude: 42.37722,
    longitude: -71.42446,
    zoom: 8.85,
    transitionDuration: 1000
  });

  const [showPopup, togglePopup] = useState(false);
  const [lngLat, setLngLat] = useState();
  const [popupSite, setPopupSite] = useState();

  const handleViewportChange = useCallback(
    (viewport: any) => setViewport(viewport), [],
  );

  const handleGeocoderViewportChange = useCallback((newViewport: any) => {
    const geocoderDefaultOverrides = { transitionDuration: 1000 };
    return handleViewportChange({
      ...newViewport,
      ...geocoderDefaultOverrides,
    });
  }, []);

  return (
      <ReactMapGL
        {...viewport}
        ref={mapRef}
        width="100vw"
        height="100%"
        onViewportChange={handleViewportChange}
        mapboxApiAccessToken="pk.eyJ1IjoiaWhpbGwiLCJhIjoiY2plZzUwMTRzMW45NjJxb2R2Z2thOWF1YiJ9.szIAeMS4c9YTgNsJeG36gg"
        mapStyle="mapbox://styles/ihill/ckzn61agl000c14qjecumnu8o"
        scrollZoom={true}
        onHover={(e: any) => {          
          if (e.features && e.features.find((row: any) => row.sourceLayer === "mapc_subregions-bdsc9m")) {
              setLngLat(e.lngLat);
              togglePopup(true);
              setPopupSite(e.features.find((row: any) => row.sourceLayer === "mapc_subregions-bdsc9m").properties);
          } else {
            togglePopup(false);
          }
        }}
      >  
        <Geocoder
          css={inputStyle}
          mapRef={mapRef}
          onViewportChange={handleGeocoderViewportChange}
          mapboxApiAccessToken="pk.eyJ1IjoiaWhpbGwiLCJhIjoiY2plZzUwMTRzMW45NjJxb2R2Z2thOWF1YiJ9.szIAeMS4c9YTgNsJeG36gg"
        />
        {popupSite ? 
          showPopup && (
            <Popup
              latitude={lngLat[1]}
              longitude={lngLat[0]}
              closeButton={false}
              onClose={() => togglePopup(false)}
              anchor="top"
            >
              <div css={popupStyle}>
                {popupSite ? 
                <div>
                  <h1 className="popup-muni">{popupSite.municipal}</h1>
                  <h2>Subregion:<br/>{popupSite.subreg}</h2>
                </div>
                :
                ""}
              </div>
            </Popup>
          )
          : !showPopup 
        }
        <Source id="Subregions" type="vector" url="mapbox://ihill.59tkk4ov">
          <Layer
            type="fill"
            id="Subregions (fill)"
            source="Subregions"
            source-layer="mapc_subregions-bdsc9m"
            paint={{
              'fill-color': [
                'match',
                ['get', 'subreg_id'],
                355,
                '#002C3D',
                356,
                '#005F73',
                357,
                '#94D2BD',
                358,
                '#EBBD34',
                359,
                '#F3D57B',
                360,
                '#CA6702',
                361,
                '#E68C31',
                362,
                '#cb4154',
                'hsla(0, 0%, 0%, 0)'
              ],
              'fill-opacity': [
                'interpolate',
                ['linear'],
                ['zoom'],
                7,
                1,
                10,
                0.8,
                13.5,
                0
              ]
            }}
          />
        </Source>
        <Source id="Municipalities" type="vector" url="mapbox://ihill.763lks2o">
          <Layer
            type="line"
            id="Municipal (line)"
            source="Municipalities"
            source-layer="MAPC_borders-0im3ea"
            paint={{
              'line-color': "slategray",
              'line-opacity': 0.8
            }}
          />
        </Source>
        <div css={navigationStyle}>
          <NavigationControl />
        </div>
      </ReactMapGL>
  );
};

export default Subregions;
