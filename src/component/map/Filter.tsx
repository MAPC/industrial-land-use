/** @jsx jsx */

import React from 'react';
import { jsx, css } from '@emotion/react';
import { themeColors, fonts } from '../../utils/theme';
import ToggleSwitch from './ToggleSwitch';
import Legend from './Legend';
import Basemap from './Basemap';

interface FilterProps {
  basemap: any,
  setBasemap: any
}

const FilterStyle = css`
  background: ${themeColors.white};
  color: navy;
  font-family: ${fonts.avenirNext};
  height: 100vh;
  padding: 0 1.5rem;
  overflow: scroll;
  width: 28rem;
  z-index: 1;
`;

const Filter = ({
  basemap,
  setBasemap
}) => {
    return (
      <div css={FilterStyle}>
        <Basemap basemap={basemap} setBasemap={setBasemap} />
        <Legend  basemap={basemap}/>
      </div>
    );
};

export default Filter;