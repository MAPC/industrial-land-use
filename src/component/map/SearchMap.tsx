/** @jsx jsx */

import React, {
  useRef, useState, useCallback, useEffect, useMemo
} from 'react';
import { jsx, css } from '@emotion/react';
import ReactMapGL, { Source, Layer, NavigationControl, Popup, GeolocateControl } from 'react-map-gl';
import Filter from './Filter';
import Basemap from './Basemap';
import Commtypes from './basemap-layers/Commtypes';
import Submarkets from './basemap-layers/Submarkets';
import Subregions from './basemap-layers/Subregions';
import Default from './basemap-layers/Default';

const mapStyle = css`
  height: 100vh;
  position: absolute;
  top: 0;
`;

const FilterContainer = css`
  align-items: center;
  display: flex;
  height: 100%;
  justify-content: start;
  position: absolute;
  width: 100%;
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

const SearchMap = () => {

  const basemapLayers = [
    'default',
    'commtypes',
    'submarkets',
    'subregions'
  ]

  const [basemap, setBasemap] = useState()
  const mapRef: any = useRef();

  useEffect(() => {
    if (mapRef && mapRef.current) {
      const map = mapRef.current.getMap();
    }
  }, [basemap]);

  const [viewport, setViewport] = useState({
    latitude: 42.37722,
    longitude: -71.42446,
    zoom: 8.85,
    transitionDuration: 1000
  });

  const [showPopup, togglePopup] = useState(false);
  const [lngLat, setLngLat] = useState();
  const [popupSite, setPopupSite] = useState();

  // Community Types
  const [type1, toggleType1] = useState(true);
  const [type2, toggleType2] = useState(true);
  const [type3, toggleType3] = useState(true);
  const [type4, toggleType4] = useState(true);
  const [type5, toggleType5] = useState(true);

  const handleViewportChange = useCallback(
    (viewport: any) => setViewport(viewport), [],
  );
  
  function renderBasemap (basemap:any) {
    if (basemap === "commtypes") {
      return <Commtypes />;
    } else if (basemap === "submarkets") {
      return <Submarkets />;
    } else if (basemap === "subregions") {
      return <Subregions />;
    } else {
      return <Default />;
    }
  }

  return (
    <div css={mapStyle}>
      <div css={FilterContainer}>
        <Filter 
          basemap={basemap}
          setBasemap={setBasemap}
          type1={type1}
          toggleType1={toggleType1}
          type2={type2}
          toggleType2={toggleType2}
          type3={type3}
          toggleType3={toggleType3}
          type4={type4}
          toggleType4={toggleType4}
          type5={type5}
          toggleType5={toggleType5}
        />
      </div>
      {renderBasemap(basemap)}
    </div>
  );
};

export default SearchMap;
