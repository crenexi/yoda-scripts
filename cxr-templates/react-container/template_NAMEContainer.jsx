import React from 'react';

// import routes from '@config/app-routes';
// import svars from '@helpers/scss/exports';
import useDataHard from '@hooks/use-data-hard';
import logger from '@services/logger';
import NAME from './NAME';

const NAMEContainer = () => {
  const hard = useDataHard();

  logger.debug('TODO: NAME');

  return <NAME />;
};

export default NAMEContainer;
