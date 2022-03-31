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

const Default = () => {

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
    >
      <Geocoder
        css={inputStyle}
        mapRef={mapRef}
        onViewportChange={handleGeocoderViewportChange}
        mapboxApiAccessToken="pk.eyJ1IjoiaWhpbGwiLCJhIjoiY2plZzUwMTRzMW45NjJxb2R2Z2thOWF1YiJ9.szIAeMS4c9YTgNsJeG36gg"
      />
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

export default Default;
