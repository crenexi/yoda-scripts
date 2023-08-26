import React from 'react';
import sy from './NAME.scss';

interface NAMEProps {
  children?: React.ReactNode;
  isReady: boolean;
}

const NAME: React.FC<NAMEProps> = (props) => {
  const { children = 'TODO', isReady } = props;

  // Loading
  if (!isReady) return null;

  return (
    <div className={sy.edge}>{children}</div>
  );
};

export default NAME;
