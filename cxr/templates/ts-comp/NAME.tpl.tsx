import React from 'react';
import sy from './NAME.scss';

interface NAMEProps {
  children?: React.ReactNode;
}

const NAME: React.FC<NAMEProps> = ({ children = 'TODO' }) => {
  const [value, setValue] = React.useState<null>(null);

  return (
    <div className={sy.edge}>{children}</div>
  );
};

export default NAME;
