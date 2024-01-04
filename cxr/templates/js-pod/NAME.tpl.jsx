import React from 'react';
import PropTypes from 'prop-types';
import sy from './NAME.scss';

const NAME = (props) => {
  const { children, isReady } = props;

  // Loading
  if (!isReady) return null;

  return (
    <div className={sy.edge}>{children}</div>
  );
};

NAME.propTypes = {
  children: PropTypes.node,
};

NAME.defaultProps = {
  children: 'TODO',
};

export default NAME;
