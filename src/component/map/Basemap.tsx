/** @jsx jsx */

import React, {useState, useEffect} from 'react';
import { jsx, css } from '@emotion/react';
import { themeColors, fonts } from '../../utils/theme';
import Select from 'react-select';

interface BasemapProps {
  basemap:any,
  setBasemap: any
}

const BasemapStyle = css`
  background: ${themeColors.white};
  color: navy;
  font-family: ${fonts.avenirNext};
  height: auto;
  z-index: 1;
`;

const Basemap = ({
  basemap,
  setBasemap
}) => {

  const options = [
    { value: 'commtypes', label: 'Community Types' },
    { value: 'submarkets', label: 'Housing Submarkets' },
    { value: 'subregions', label: 'Subregions' },
    { value: 'default', label: 'Default' },
  ]

  const [selectedOption, setSelectedOption] = useState("default");

  useEffect(() => {
    setBasemap(selectedOption.value)
  }, [selectedOption])

  return (
    <div css={BasemapStyle}>
      <h1>Basemap</h1>
      <Select 
        defaultValue={selectedOption}
        options={options} 
        placeholder="Select a Basemap" 
        onChange={setSelectedOption} 
      />
    </div>
  );
};

export default Basemap;