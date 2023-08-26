import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';

import useDataStatic from '@hooks/use-data-static';
import useDataFirebase from '@hooks/use-data-firebase';
import logger from '@services/logger';
import NAME from './NAME';

const NAMEContainer = () => {
  logger.debug('TODO: NAME');

  const dStatic = useDataStatic();
  const dFire = useDataFirebase();

  // URL params
  const { param1 } = useParams();

  // State
  const [isReady, setIsReady] = useState(false);

  // URL param effects
  useEffect(() => {
    logger.debug(`Param1: ${param1}`);
  }, [param1]);

  useEffect(() => {
    setIsReady(true);
  }, [])

  return <NAME isReady={isReady} />;
};

export default NAMEContainer;
