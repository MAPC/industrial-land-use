/** @jsx jsx */

import React from 'react';
import { css, jsx } from '@emotion/react';
import { Helmet } from 'react-helmet';
import Layout from '../component/Layout';
import Wrapper from '../component/map/Wrapper';
import { themeColors, marginStyle } from '../utils/theme';

const impactH3Style = css`
  color: ${themeColors.indigo};
  font-size: 2.8rem;
  margin-top: 0;
`;

const IndexPage = () => (
  <React.Fragment>
    <Helmet>
      <title>Industrial Land Use</title>
      <link href='https://api.mapbox.com/mapbox-gl-js/plugins/mapbox-gl-geocoder/v4.2.0/mapbox-gl-geocoder.css' rel='stylesheet' />
    </Helmet>
    <Layout>
      <main>
        <div css={marginStyle}>
          <Wrapper />
        </div>
      </main>
    </Layout>
  </React.Fragment>
);

export default IndexPage;
