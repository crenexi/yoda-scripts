import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';

import useDataStatic from '@hooks/use-data-static';
import useDataFirebase from '@hooks/use-data-firebase';
import logger from '@services/logger';
import NAME from './NAME';

interface Params {
  param1?: string; // Assuming param1 is of type string, adjust as necessary.
}

const NAMEPod: React.FC = () => {
  logger.debug('TODO: NAME');

  const dStatic = useDataStatic();
  const dFire = useDataFirebase();

  // URL params
  const { param1 } = useParams<Params>();

  // State
  const [isReady, setIsReady] = useState<boolean>(false);

  // URL param effects
  useEffect(() => {
    if (param1) {
      logger.debug(`Param1: ${param1}`);
    }
  }, [param1]);

  useEffect(() => {
    setIsReady(true);
  }, [])

  return <NAME isReady={isReady} />;
};

export default NAMEPod;
