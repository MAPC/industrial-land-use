/** @jsx jsx */

import React, { useEffect } from 'react';
import { jsx, css } from '@emotion/react';

interface LegendProps {
  basemap: any
}

const legendStyle = css`
  padding-bottom: 3rem;
  .dot {
    border-radius: 50%;
    display: inline-block;
    height: 15px;
    margin: 0 5px;
    width: 15px;
  }
  p {
    display: inline;
  }
`;

const Commtypes = 
  <div css={legendStyle}>
    <h1>Community Types</h1>
    <h3>Inner Core</h3>
    <span className="dot" style={{backgroundColor: "#002C3D"}}></span>
    <p>Metro Core Community</p><br/>
    <span className="dot" style={{backgroundColor: "#005F73"}}></span>
    <p>Streetcar Suburb</p><br/>
    <h3>Regional Urban Center</h3>
    <span className="dot" style={{backgroundColor: "#94D2BD"}}></span>
    <p>Sub-Regional Urban Center</p><br/>
    <h3>Maturing Suburb</h3>
    <span className="dot" style={{backgroundColor: "#EBBD34"}}></span>
    <p>Mature Suburb</p><br/>
    <span className="dot" style={{backgroundColor: "#F3D57B"}}></span>
    <p>Established Suburb/Cape Cod Town</p><br/>
    <h3>Developing Suburb</h3>
    <span className="dot" style={{backgroundColor: "#CA6702"}}></span>
    <p>Maturing New England Town</p><br/>
    <span className="dot" style={{backgroundColor: "#E68C31"}}></span>
    <p>Country Suburb</p><br/>
  </div>;

const Submarkets = 
  <div css={legendStyle}>
    <h1>Housing Submarkets</h1>
    <h3>Submarket 1</h3>
    <span className="dot" style={{backgroundColor: "#002C3D"}}></span>
    <p>High-Density Urban, High Prices</p><br/>

    <h3>Submarket 2</h3>
    <span className="dot" style={{backgroundColor: "#005F73"}}></span>
    <p>High-Density Urban, Lower Prices</p><br/>

    <h3>Submarket 3</h3>
    <span className="dot" style={{backgroundColor: "#94D2BD"}}></span>
    <p>Moderate-Density Urban, Moderate Prices</p><br/>

    <h3>Submarket 4</h3>
    <span className="dot" style={{backgroundColor: "#EBBD34"}}></span>
    <p>Low-Density Urban-Suburban Mix, Lower Prices</p><br/>

    <h3>Submarket 5</h3>
    <span className="dot" style={{backgroundColor: "#F3D57B"}}></span>
    <p>Low-Density Suburban, Highest Prices</p><br/>

    <h3>Submarket 6</h3>
    <span className="dot" style={{backgroundColor: "#CA6702"}}></span>
    <p>Low-Density Suburban, Mixed Prices</p><br/>
    
    <h3>Submarket 7</h3>
    <span className="dot" style={{backgroundColor: "#E68C31"}}></span>
    <p>Low-Density Suburban, Moderate Prices</p><br/>
  </div>;

const Subregions = 
  <div css={legendStyle}>
    <h1>MAPC Subregions</h1>
    <h3>Inner Core</h3>
    <span className="dot" style={{backgroundColor: "#002C3D"}}></span>
    <p>Inner Core Committee (ICC)</p><br/>

    <h3>MAGIC</h3>
    <span className="dot" style={{backgroundColor: "#005F73"}}></span>
    <p>Minuteman Advisory Group on Interlocal Coordination (MAGIC)</p><br/>

    <h3>MetroWest</h3>
    <span className="dot" style={{backgroundColor: "#94D2BD"}}></span>
    <p>MetroWest Regional Collaborative (MetroWest)</p><br/>

    <h3>NSPC</h3>
    <span className="dot" style={{backgroundColor: "#EBBD34"}}></span>
    <p>North Suburban Planning Council (NSPC)</p><br/>

    <h3>NSTF</h3>
    <span className="dot" style={{backgroundColor: "#F3D57B"}}></span>
    <p>North Shore Task Force (NSTF)</p><br/>

    <h3>SSC</h3>
    <span className="dot" style={{backgroundColor: "#CA6702"}}></span>
    <p>South Shore Coalition (SSC)</p><br/>
    
    <h3>SWAP</h3>
    <span className="dot" style={{backgroundColor: "#E68C31"}}></span>
    <p>South West Advisory Planning Committe (SWAP)</p><br/>

    <h3>TRIC</h3>
    <span className="dot" style={{backgroundColor: "#cb4154"}}></span>
    <p>Three Rivers Interlocal Council (TRIC)</p><br/>
  </div>;

const Legend = ({basemap}) => {

  useEffect(() => {
    renderLegend(basemap)
  }, [basemap])

  function renderLegend (basemap:any) {
    if (basemap === "commtypes") {
      return Commtypes;
    } else if (basemap === "submarkets") {
      return Submarkets;
    } else if (basemap === "subregions") {
      return Subregions;
    } else {
      return undefined;
    }
  }

  return (
    <div>
      {renderLegend(basemap)}
    </div>
  );
};

export default Legend;