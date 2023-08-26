import React, { useState, useEffect } from 'react';
import useDataStatic from '@hooks/use-data-static';
import useDataFirebase from '@hooks/use-data-firebase';
import logger from '@services/logger';
import NAME from './NAME';

const NAMEContainer = () => {
  logger.debug('TODO: NAME');

  const dStatic = useDataStatic();
  const dFire = useDataFirebase();

  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    setIsReady(true);
  }, [])

  return <NAME isReady={isReady} />;
};

export default NAMEContainer;
